defmodule HTS221.Humidity do
  @moduledoc """
  Humidity Registers

  This module is useful for reading the values from the humidity registers
  (0x28, 0x29) and providing both the individual readings and the complete raw
  16-bit integer.
  """

  @type t() :: %__MODULE__{
          humidity_out_h: byte(),
          humidity_out_l: byte(),
          raw: HTS221.s16()
        }

  defstruct humidity_out_l: nil, humidity_out_h: nil, raw: nil

  @spec from_binary(binary()) :: t()
  def from_binary(<<hum_out_l, hum_out_h>> = binary) do
    <<hum::signed-integer-little-size(2)-unit(8)>> = binary

    %__MODULE__{
      humidity_out_h: hum_out_h,
      humidity_out_l: hum_out_l,
      raw: hum
    }
  end

  defimpl HTS221.Register do
    alias HTS221.IORead

    def read(_) do
      {:ok, IORead.new(0x28, 2)}
    end

    def write(_) do
      {:error, :access_error}
    end
  end
end
