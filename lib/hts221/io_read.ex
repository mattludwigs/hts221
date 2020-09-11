defmodule HTS221.IORead do
  @moduledoc """
  Data structure that provides information about how to read registers

  This is only useful if you are implementing the `HTS221.Register` protocol.

  If the `:length` field is more than one, then the read will read `length`
  number of registers sequentially.

  For example:

  ```
  %HTS221.IORead{
    register: 0x01,
    length: 5
  }
  ```

  This will read registers `0x01` to `0x05` and provide a `5` byte binary
  string.
  """

  @type t() :: %__MODULE__{
          register: byte(),
          length: non_neg_integer()
        }

  @enforce_keys [:register, :length]
  defstruct register: nil, length: nil

  @doc """
  Create a new `HTS221.IORead` data structure
  """
  @spec new(byte(), non_neg_integer()) :: t()
  def new(register, length) do
    %__MODULE__{
      register: register,
      length: length
    }
  end
end
