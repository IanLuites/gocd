defmodule GoCD.Error do
  @moduledoc ~S"""
  GoCD request error.
  """

  @typedoc @moduledoc
  @type t :: %__MODULE__{
          message: String.t()
        }

  defstruct [:message]
end
