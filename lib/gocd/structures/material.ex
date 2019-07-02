defmodule GoCD.Material do
  @moduledoc ~S"""
  GoCD material.

  TODO: more info.
  """

  @derive Jason.Encoder
  @typedoc @moduledoc
  @type t :: %__MODULE__{
          type: :git,
          description: String.t(),
          fingerprint: String.t()
        }

  @type type :: :git | :svn | :hg | :p4 | :tfs | :dependency | :package | :plugin

  @types %{
    "dependency" => :dependency,
    "git" => :git,
    "hg" => :hg,
    "p4" => :p4,
    "package" => :package,
    "plugin" => :plugin,
    "svn" => :svn,
    "tfs" => :tfs
  }

  defstruct [
    :type,
    :description,
    :fingerprint
  ]

  @doc ~S"""
  Parse a GoCD material.
  """
  @spec parse(map) :: {:ok, t} | {:error, atom}
  def parse(data) do
    type = String.downcase(MapX.get(data, :type, ""))

    case @types[type] do
      type when is_atom(type) ->
        {:ok,
         %__MODULE__{
           description: MapX.get(data, :description),
           fingerprint: MapX.get(data, :fingerprint),
           type: type
         }}

      _ ->
        {:error, :invalid_material_type}
    end
  end
end
