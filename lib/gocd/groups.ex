defmodule GoCD.Groups do
  @moduledoc false
  alias GoCD.{Group}

  @doc ~S"""
  Get a GoCD group config.
  """
  @spec get(module, String.t()) :: {:ok, Group.t()} | {:error, any}
  def get(server, group) do
    with {:ok, groups} <- list(server) do
      if group = Enum.find(groups, &(&1.name == group)),
        do: {:ok, group},
        else: {:error, :unknown_group}
    end
  end

  @doc ~S"""
  List all GoCD config groups.
  """
  @spec list(module) :: {:ok, [Group.t()]} | {:error, any}
  def list(server) do
    with {:ok, data} <- server.get(0, "/go/api/config/pipeline_groups") do
      EnumX.map(data, &Group.parse/1)
    end
  end

  @doc ~S"""
  Check whether a GoCD config group exists.
  """
  @spec exists?(module, String.t()) :: boolean
  def exists?(server, group), do: server |> get(group) |> elem(0) |> Kernel.==(:ok)
end
