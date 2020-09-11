defmodule HTS221.IOWrite do
  @moduledoc """
  Data structure about writing to registers

  This is only useful if you are implementing the `HTS221.Register` protocol.

  This only has one field `:payload` but the register you writing to should be
  the first byte in the binary.

  ```
  register = 0x01

  %HTS221.IOWrite{
    payload: <<register, 0x01>>
  }
  ```

  The above example says to write `0x01` to the `0x01` register.
  """

  @type t() :: %__MODULE__{
          payload: binary()
        }

  @enforce_keys [:payload]
  defstruct payload: nil

  @doc """
  Create a new `HTSS221.IOWrite` data structure
  """
  @spec new(binary()) :: t()
  def new(payload) do
    %__MODULE__{payload: payload}
  end
end
