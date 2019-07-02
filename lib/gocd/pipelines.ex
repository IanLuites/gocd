defmodule GoCD.Pipelines do
  @moduledoc false
  alias GoCD.{Crypt, EnvironmentVariable, Group, Groups, Pipeline}

  @typedoc false
  @type id :: String.t() | Pipeline.t()

  @doc ~S"""
  Schedule (trigger) a GoCD pipeline.
  """
  @spec schedule(module, id, Keyword.t()) :: :ok | {:error, any}
  def schedule(server, pipeline, opts \\ [])

  def schedule(server, pipeline, opts) do
    ciphers = server.__config__(:ciphers)
    update = Keyword.get(opts, :update_materials_before_scheduling, true)
    env_vars = Keyword.get(opts, :environment_variables, [])

    # Prep env vars
    {:ok, env_vars} =
      EnumX.map(env_vars, fn
        {var, value} ->
          {:ok, %{name: var, value: value, secure: false}}

        {var, value, true} ->
          with {:ok, encrypted} <- Crypt.encrypt(value, ciphers),
               do: %{name: var, value: encrypted, secure: true}
      end)

    server.post(
      1,
      "/go/api/pipelines/#{pipeline}/schedule",
      {:json,
       %{
         environment_variables: env_vars,
         update_materials_before_scheduling: update
       }}
    )
  end

  @doc ~S"""
  Pause a GoCD pipeline.
  """
  @spec pause(module, id, String.t() | nil) :: :ok | {:error, any}
  def pause(server, pipeline, reason \\ nil)

  def pause(server, %Pipeline{name: name}, reason), do: pause(server, name, reason)

  def pause(server, name, reason) do
    with {:ok, _} <-
           server.post(1, "/go/api/pipelines/#{name}/pause", {:json, %{pause_cause: reason}}),
         do: :ok
  end

  @doc ~S"""
  Resume a GoCD pipeline.
  """
  @spec unpause(module, id) :: :ok | {:error, atom}
  def unpause(server, %Pipeline{name: name}), do: unpause(server, name)

  def unpause(server, name) do
    with {:ok, _} <-
           server.post(1, "/go/api/pipelines/#{name}/unpause", "",
             format: :text,
             headers: [{"Confirm", "true"}]
           ),
         do: :ok
  end

  @doc ~S"""
  Get a GoCD pipeline config.
  """
  @spec get(module, id) :: {:ok, Pipeline.t()} | {:error, any}
  def get(server, name) do
    with {:ok, data} <- server.get(4, "/go/api/admin/pipelines/#{name}") do
      Pipeline.parse(data)
    end
  end

  @doc ~S"""
  List GoCD pipelines.
  """
  @spec list(module, String.t() | nil) :: {:ok, [Pipeline.t()]} | {:error, any}
  def list(server, nil),
    do: with({:ok, data} <- Groups.list(server), do: {:ok, Enum.flat_map(data, & &1.pipelines)})

  def list(server, group) do
    with {:ok, %Group{pipelines: pipelines}} <- Groups.get(server, group) do
      {:ok, pipelines}
    end
  end

  @doc ~S"""
  Check whether a GoCD pipeline exists.
  """
  @spec exists?(module, id) :: boolean
  def exists?(server, pipeline), do: server |> get(pipeline) |> elem(0) |> Kernel.==(:ok)

  @doc ~S"""
  Get GoCD pipeline's environment variables.

  Pass `decrypt: true` to decrypt encrypted variables.
  """
  @spec environment_variables(module, id, Keyword.t()) ::
          {:ok, [EnvironmentVariable.t()]} | {:error, any}
  def environment_variables(server, pipeline, opts \\ [])

  def environment_variables(server, %{environment_variables: env_vars}, opts) do
    if opts[:decrypt], do: decrypt_env_vars(env_vars, server), else: {:ok, env_vars}
  end

  def environment_variables(server, %{name: name}, opts),
    do: environment_variables(server, name, opts)

  def environment_variables(server, pipeline, opts) do
    with {:ok, pipeline} <- get(server, pipeline),
         do: environment_variables(server, pipeline, opts)
  end

  @spec decrypt_env_vars([EnvironmentVariable.t()], module) ::
          {:ok, [EnvironmentVariable.t()]} | {:error, atom}
  defp decrypt_env_vars(env_vars, server) do
    ciphers = server.__config__(:ciphers)

    EnumX.map(
      env_vars,
      fn
        env_var = %{encrypted_value: encrypted, secure: true} ->
          with {:ok, decrypted} <- Crypt.decrypt(encrypted, ciphers),
               do: {:ok, Map.put(env_var, :value, decrypted)}

        env_var = %{secure: false} ->
          {:ok, env_var}

        _ ->
          {:error, :secure_env_var_without_encrypted_value}
      end
    )
  end
end
