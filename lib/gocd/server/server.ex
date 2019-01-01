defmodule GoCD.Server do
  @moduledoc false
  defmacro __using__(opts \\ []) do
    quote location: :keep do
      use GoCD.Server.Config, unquote(opts)
      use GoCD.Server.API, unquote(opts)
      use GoCD.Server.Convenience, unquote(opts)
    end
  end
end
