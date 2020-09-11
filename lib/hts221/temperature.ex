defmodule HTS221.Temperature do
  @moduledoc """
  Temperature Registers

  This module abstracts over the two temperature registers (0x2A, 0x2B) and
  provide functionally to read both at once to provide the raw ADC data on in
  the two registers.
  """

  @type t() :: %__MODULE__{
          temp_out_l: byte(),
          temp_out_h: byte(),
          raw: 0..65535
        }

  defstruct temp_out_l: nil, temp_out_h: nil, raw: nil

  @spec from_binary(binary()) :: t()
  def from_binary(<<temp_out_l, temp_out_h>> = binary) do
    <<temp::signed-integer-little-size(2)-unit(8)>> = binary

    %__MODULE__{
      temp_out_l: temp_out_l,
      temp_out_h: temp_out_h,
      raw: temp
    }
  end

  defimpl HTS221.Register do
    alias HTS221.IORead

    def read(_) do
      {:ok, IORead.new(0x2A, 2)}
    end

    def write(_) do
      {:error, :access_error}
    end
  end
end
