defmodule GoCD.Server.Convenience do
  @moduledoc false

  @doc false
  defmacro __using__(_opts \\ []) do
    quote do
      alias GoCD.{EnvironmentVariable, Group, Groups, Material, Materials, Pipeline, Pipelines}

      @doc ~S"""
      GoCD server version.
      """
      @spec version :: GoCD.Server.Version.t()
      def version, do: __config__().version

      @doc ~S"""
      See: `schedule/2`.
      """
      @spec trigger(Pipelines.id(), Keyword.t()) :: :ok | {:error, any}
      def trigger(pipeline, opts \\ []),
        do: schedule(pipeline, opts)

      @doc ~S"""
      Schedule (trigger) a GoCD pipeline.
      """
      @spec schedule(Pipelines.id(), Keyword.t()) :: :ok | {:error, any}
      def schedule(pipeline, opts \\ []),
        do: Pipelines.schedule(__MODULE__, pipeline, opts)

      @doc ~S"""
      Pause a GoCD pipeline.
      """
      @spec pause(Pipelines.id(), String.t() | nil) :: :ok | {:error, any}
      def pause(pipeline, reason \\ nil),
        do: Pipelines.pause(__MODULE__, pipeline, reason)

      @doc ~S"""
      Resume a GoCD pipeline.
      """
      @spec unpause(Pipelines.id()) :: :ok | {:error, atom}
      def unpause(pipeline), do: Pipelines.unpause(__MODULE__, pipeline)

      @doc ~S"""
      Check whether a GoCD pipeline exists.
      """
      @spec pipeline_exists?(Pipelines.id()) :: boolean
      def pipeline_exists?(name), do: Pipelines.exists?(__MODULE__, name)

      @doc ~S"""
      Get a GoCD pipeline config.
      """
      @spec pipeline(Pipelines.id()) :: {:ok, Pipeline.t()} | {:error, any}
      def pipeline(name), do: Pipelines.get(__MODULE__, name)

      @doc ~S"""
      Create a new GoCD pipeline [config].
      """
      @spec create(String.t(), String.t(), Keyword.t()) ::
              {:ok, Pipeline.t()} | {:error, any}
      def create(name, group, opts \\ []), do: Pipelines.create(__MODULE__, name, group, opts)

      @doc ~S"""
      List GoCD pipelines.
      """
      @spec pipelines(String.t() | nil) :: {:ok, [Pipeline.t()]} | {:error, any}
      def pipelines(group \\ nil), do: Pipelines.list(__MODULE__, group)

      @doc ~S"""
      Get GoCD pipeline's environment variables.

      Pass `decrypt: true` to decrypt encrypted variables.
      """
      @spec environment_variables(Pipelines.id(), Keyword.t()) ::
              {:ok, [EnvironmentVariable.t()]} | {:error, any}
      def environment_variables(pipeline, opts \\ []) do
        Pipelines.environment_variables(__MODULE__, pipeline, opts)
      end

      @doc ~S"""
      Check whether a GoCD config group exists.
      """
      @spec group_exists?(String.t()) :: boolean
      def group_exists?(name), do: Groups.exists?(__MODULE__, name)

      @doc ~S"""
      Get a GoCD group config.
      """
      @spec group(String.t()) :: {:ok, Group.t()} | {:error, any}
      def group(name), do: Groups.get(__MODULE__, name)

      @doc ~S"""
      List all GoCD config groups.
      """
      @spec groups :: {:ok, [Group.t()]} | {:error, any}
      def groups, do: Groups.list(__MODULE__)

      @doc ~S"""
      List all GoCD materials.
      """
      @spec materials :: {:ok, [Material.t()]} | {:error, any}
      def materials, do: Materials.list(__MODULE__)
    end
  end
end
