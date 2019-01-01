defmodule GoCD.Materials do
  @moduledoc false
  alias GoCD.{Material}

  @doc ~S"""
  List all GoCD materials.
  """
  @spec list(module) :: {:ok, [Material.t()]} | {:error, any}
  def list(server) do
    with {:ok, data} <- server.get(1, "/go/api/config/materials") do
      EnumX.map(data, &Material.parse/1)
    end
  end
end
