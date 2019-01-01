defmodule GoCD do
  @moduledoc ~S"""
  GoCD client for Elixir.
  """
  alias GoCD.Server.{API, Version}

  @doc ~S"""
  Check the GoCD server version.
  """
  @spec version(String.t(), any | nil) :: {:ok, Version.t()} | {:error, atom}
  def version(url, proxy \\ nil) do
    with {:ok, version_data} <- API.get("/go/api/version", server: url, proxy: proxy, version: 1) do
      Version.parse(version_data)
    end
  end
end
