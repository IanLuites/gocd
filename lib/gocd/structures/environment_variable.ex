defmodule GoCD.EnvironmentVariable do
  @moduledoc ~S"""
  GoCD environment variable.
  """

  @typedoc @moduledoc
  @type t :: %__MODULE__{
          name: String.t(),
          value: String.t() | :encrypted,
          secure: boolean,
          encrypted_value: String.t() | nil
        }

  defstruct [
    :name,
    :value,
    :secure,
    :encrypted_value
  ]

  @doc ~S"""
  Parse a GoCD environment variable.
  """
  @spec parse(map) :: {:ok, t} | {:error, atom}
  def parse(data) do
    with name when is_binary(name) <-
           MapX.get(data, :name) || {:error, :invalid_environment_variable_name} do
      {:ok,
       %__MODULE__{
         name: name,
         value: MapX.get(data, :value, :encrypted),
         secure: MapX.get(data, :secure, false),
         encrypted_value: MapX.get(data, :encrypted_value, nil)
       }}
    end
  end

  defimpl Inspect, for: __MODULE__ do
    def inspect(%{secure: secure, value: value, name: name}, _opts) do
      cond do
        value == :encrypted -> "#EnvVar<🔒#{name}>"
        secure -> "#EnvVar<🔓#{name}>"
        not secure -> "#EnvVar<#{name}>"
      end
    end
  end
end
