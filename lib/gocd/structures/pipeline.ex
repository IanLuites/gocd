defmodule GoCD.Pipeline do
  @moduledoc ~S"""
  GoCD pipeline.

  TODO: more info.
  """
  alias GoCD.{EnvironmentVariable, Material, Stage}

  @typedoc @moduledoc
  @type t :: %__MODULE__{
          name: String.t(),
          label: String.t(),
          materials: any,
          stages: any,
          environment_variables: [map]
        }

  defstruct [
    :name,
    :label,
    :materials,
    :stages,
    :environment_variables
  ]

  @doc ~S"""
  Parse GoCD pipeline.
  """
  @spec parse(map) :: {:ok, t} | {:error, atom}
  def parse(data) do
    stages =
      case MapX.get(data, :stages, []) do
        nil -> :not_loaded
        stages -> Enum.map(stages, &%Stage{name: &1.name})
      end

    with {:ok, materials} <- EnumX.map(MapX.get(data, :materials, []), &Material.parse/1),
         {:ok, env_var} <-
           EnumX.map(MapX.get(data, :environment_variables, []), &EnvironmentVariable.parse/1) do
      {:ok,
       %__MODULE__{
         name: MapX.get(data, :name),
         label: MapX.get(data, :label),
         materials: materials,
         stages: stages,
         environment_variables: env_var
       }}
    end
  end
end
