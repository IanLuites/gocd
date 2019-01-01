defmodule GoCD.Server.Version do
  @moduledoc ~S"""
  GoCD server version.
  """

  @typedoc @moduledoc
  @type t :: %__MODULE__{
          build_number: non_neg_integer,
          commit_url: String.t(),
          full_version: String.t(),
          git_sha: String.t(),
          version: Version.t()
        }

  defstruct [
    :build_number,
    :commit_url,
    :full_version,
    :git_sha,
    :version
  ]

  @doc ~S"""
  Parse GoCD server version.
  """
  @spec parse(map) :: {:ok, t} | {:error, atom}
  def parse(data) do
    with {:ok, version} <- Version.parse(MapX.get(data, :version)),
         {build, ""} <- Integer.parse(MapX.get(data, :build_number)) do
      {:ok,
       %__MODULE__{
         version: version,
         build_number: build,
         commit_url: MapX.get(data, :commit_url),
         full_version: MapX.get(data, :full_version),
         git_sha: MapX.get(data, :git_sha)
       }}
    else
      error = {:error, _} -> error
      :error -> {:error, :invalid_server_version}
    end
  end
end
