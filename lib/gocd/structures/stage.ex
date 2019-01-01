defmodule GoCD.Stage do
  @moduledoc ~S"""
  GoCD stage.

  TODO: more info.
  """

  @typedoc @moduledoc
  @type t :: %__MODULE__{
          name: String.t()
        }

  defstruct [
    :name
  ]
end
