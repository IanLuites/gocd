defmodule GoCD.Server.Config do
  @moduledoc ~S"""
  GoCD server configuration.
  """
  alias GoCD.Server.{Version}

  @typedoc @moduledoc
  @type t :: %__MODULE__{
          url: String.t(),
          ciphers: %{des: binary | nil, aes: binary | nil},
          proxy: Keyword.t() | nil,
          version: Version.t()
        }

  @enforce_keys [:url, :version]
  defstruct [
    :url,
    :ciphers,
    :proxy,
    :version
  ]

  @doc false
  @spec parse(module, Keyword.t()) :: {:ok, t} | {:error, atom}
  def parse(server, opts \\ []) do
    otp_config = Application.get_env(server.__config__(:otp_app), server) || []
    proxy = otp_config[:proxy] || opts[:proxy]
    ciphers = otp_config[:ciphers] || opts[:ciphers] || []

    with url when is_binary(url) <- otp_config[:url] || opts[:url] || {:error, :missing_gocd_url},
         url <- String.trim_trailing(url, "/"),
         {:ok, version} <- GoCD.version(url, proxy),
         {:ok, des} <- parse_cipher(ciphers[:des]),
         {:ok, aes} <- parse_cipher(ciphers[:aes]) do
      {:ok,
       %__MODULE__{
         url: url,
         version: version,
         proxy: proxy,
         ciphers: %{
           des: des,
           aes: aes
         }
       }}
    end
  end

  @spec parse_cipher(String.t() | nil) :: {:ok, binary | nil} | {:error, atom}
  defp parse_cipher(nil), do: {:ok, nil}

  defp parse_cipher(data) do
    data
    |> String.upcase()
    |> Base.decode16()
  end

  ### Config Server ###

  @doc false
  defmacro __using__(opts \\ []) do
    otp_app = opts[:otp_app] || raise "Need to set `otp_app` for configuration."

    quote location: :keep do
      alias GoCD.Server.Config

      ### Config ###

      @doc false
      @spec __config__ :: Config.t()
      def __config__, do: GenServer.call(__MODULE__, :config)

      @doc false
      @spec __config__(atom) :: term
      def __config__(:otp_app), do: unquote(otp_app)

      def __config__(field) do
        config = __config__()

        Map.get_lazy(config, field, fn ->
          :erlang.apply(Config, field, [config])
        end)
      end

      ### Config GenServer ###

      use GenServer
      require Logger

      @doc false
      @spec child_spec(Keyword.t()) :: map
      def child_spec(_ \\ []),
        do: %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, []}
        }

      @doc false
      @spec start_link :: {:ok, pid} | {:error, any}
      def start_link do
        with {:ok, config} <- Config.parse(__MODULE__, unquote(opts)) do
          Logger.info(
            "GoCD connected to #{URI.parse(config.url).host} server. (v#{config.version.version})"
          )

          GenServer.start_link(__MODULE__, config, name: __MODULE__)
        end
      end

      @impl GenServer
      def init(config), do: {:ok, config}

      @impl GenServer
      def handle_call(:config, _from, config), do: {:reply, config, config}

      ### Spec Fixes ###
      @spec code_change(term, term, term) :: {:ok, term} | {:error, term} | {:down, term}
      @spec handle_info(msg :: :timeout | term, state :: term) ::
              {:noreply, term}
              | {:noreply, term, timeout | :hibernate | {:continue, term}}
              | {:stop, term :: term, term}

      @spec handle_cast(request :: term, state :: term) ::
              {:noreply, term}
              | {:noreply, term, timeout | :hibernate | {:continue, term}}
              | {:stop, term :: term, term}

      @spec handle_call(request :: term, tuple, state :: term) ::
              {:reply, term, term}
              | {:reply, term, term, timeout | :hibernate | {:continue, term}}
              | {:noreply, term}
              | {:noreply, term, timeout | :hibernate, {:continue, term}}
              | {:stop, term, term, term}
              | {:stop, term, term}
      @spec init(args :: term) ::
              {:ok, any}
              | {:ok, any, timeout | :hibernate | {:continue, term}}
              | :ignore
              | {:stop, reason :: any}

      @spec terminate(:normal | :shutdown | {:shutdown, term}, state :: term) :: term
    end
  end
end
