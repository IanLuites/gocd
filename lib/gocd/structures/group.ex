defmodule GoCD.Group do
  @moduledoc ~S"""
  GoCD pipeline group.
  """
  alias GoCD.Pipeline

  @typedoc @moduledoc
  @type t :: %__MODULE__{
          name: String.t(),
          pipelines: [Pipeline.t()]
        }

  defstruct [
    :name,
    :pipelines
  ]

  @doc ~S"""
  Parse a GoCD group.
  """
  @spec parse(map) :: {:ok, t} | {:error, atom}
  def parse(data) do
    with name when is_binary(name) <- MapX.get(data, :name) || {:error, :invalid_group_name},
         {:ok, pipelines} <- EnumX.map(Map.get(data, :pipelines, []), &Pipeline.parse/1) do
      {:ok,
       %__MODULE__{
         name: name,
         pipelines: pipelines
       }}
    end
  end
end
