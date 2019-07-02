defmodule GoCD.Server.API do
  @moduledoc false

  @doc false
  @spec get(String.t(), Keyword.t()) :: {:ok, term} | {:error, any}
  def get(endpoint, opts \\ []) do
    endpoint
    |> url(opts[:server])
    |> HTTPX.get(config(opts))
    |> handle()
  end

  @doc false
  @spec post(String.t(), HTTPX.post_body(), Keyword.t()) :: {:ok, term} | {:error, any}
  def post(endpoint, body, opts \\ []) do
    endpoint
    |> url(opts[:server])
    |> HTTPX.post(body, config(opts))
    |> handle()
  end

  @spec handle(tuple) :: {:ok, term} | {:error, any}
  defp handle(response) do
    with {:ok, %{status: status, body: data}} <- response do
      if status in 200..299, do: {:ok, data}, else: {:error, struct!(GoCD.Error, data)}
    end
  end

  @spec url(String.t(), String.t()) :: String.t()
  defp url(endpoint, server), do: to_string(URI.merge(server, endpoint))

  @spec accept_version(non_neg_integer) :: String.t()
  defp accept_version(0), do: "application/json"
  defp accept_version(v), do: "application/vnd.go.cd.v#{v}+json"

  @spec config(Keyword.t()) :: Keyword.t()
  defp config(opts) do
    base = [
      format: :json_atoms,
      settings: [
        pool: opts[:pool] || :default,
        proxy: opts[:proxy]
      ]
    ]

    base =
      if v = Keyword.get(opts, :version, false) do
        Keyword.put(base, :headers, [{"Accept", accept_version(v)}])
      else
        base
      end

    Keyword.merge(base, opts, fn
      :headers, v1, v2 -> v1 ++ v2
      :settings, v1, v2 -> Keyword.merge(v1, v2)
      _key, _v1, v2 -> v2
    end)
  end

  defmacro __using__(_opts \\ []) do
    quote do
      alias GoCD.Server.API

      @typedoc false
      @type version :: non_neg_integer | (Version.t() -> non_neg_integer)

      @spec api_config(version) :: {:ok, Keyword.t()} | {:error, :no_valid_version_given}
      defp api_config(version) do
        config = __config__()
        base = [proxy: config.proxy, server: config.url, pool: __MODULE__]

        cond do
          is_integer(version) -> {:ok, [{:version, version} | base]}
          version = version.(config.version.version) -> {:ok, [{:version, version} | base]}
          :no_valid_version -> {:error, :no_valid_version_given}
        end
      end

      @doc false
      @spec get(version, String.t()) :: {:ok, map} | {:error, any}
      def get(version \\ 0, endpoint) do
        with {:ok, opts} <- api_config(version), do: API.get(endpoint, opts)
      end

      @doc false
      @spec post(version, String.t(), HTTPX.post_body()) :: {:ok, map} | {:error, any}
      def post(version \\ 0, endpoint, body, opts \\ []) do
        with {:ok, o} <- api_config(version), do: API.post(endpoint, body, Keyword.merge(o, opts))
      end
    end
  end
end
