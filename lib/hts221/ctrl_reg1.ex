defmodule HTS221.CTRLReg1 do
  @moduledoc """
  Control the power state, data rate, and update strategy of the HTS221
  """

  import Bitwise

  @power_mode_active 0x80
  @wait_for_reading 0x04
  @one_Hz 0x01
  @seven_Hz 0x02
  @twelve_point_five_Hz 0x03

  @type power_mode() :: :down | :active

  @type block_data_update() :: :continuous | :wait_for_reading

  @type output_data_rate() :: :one_shot | :one_Hz | :seven_Hz | :twelve_point_five_Hz

  @type t() :: %__MODULE__{
          power_mode: power_mode(),
          block_data_update: block_data_update(),
          output_data_rate: output_data_rate()
        }

  defstruct power_mode: :down, block_data_update: :continuous, output_data_rate: :one_shot

  @doc """
  Parse the binary into a `HTS221.CTRLReg1` structure
  """
  @spec from_binary(binary()) :: t()
  def from_binary(
        <<power_mode::size(1), _reserved::size(4), block_data_update::size(1), odr::size(2)>>
      ) do
    %__MODULE__{
      power_mode: power_mode_from_bit(power_mode),
      block_data_update: block_data_update_from_bit(block_data_update),
      output_data_rate: output_data_rate_from_int(odr)
    }
  end

  @doc """
  Turn the `HTS221.CTRLReg1` structure into a binary to be sent to the transport
  layer
  """
  @spec to_binary(t()) :: binary()
  def to_binary(ctrl_reg1) do
    <<0x20, fields_to_byte(ctrl_reg1)>>
  end

  defp power_mode_from_bit(0), do: :down
  defp power_mode_from_bit(1), do: :active

  defp block_data_update_from_bit(0), do: :continuous
  defp block_data_update_from_bit(1), do: :wait_for_reading

  defp output_data_rate_from_int(0), do: :one_shot
  defp output_data_rate_from_int(1), do: :one_Hz
  defp output_data_rate_from_int(2), do: :seven_Hz
  defp output_data_rate_from_int(3), do: :twelve_point_five_Hz

  defp fields_to_byte(ctrl_reg1) do
    0
    |> mask_with_field(:power_mode, ctrl_reg1.power_mode)
    |> mask_with_field(:block_data_update, ctrl_reg1.block_data_update)
    |> mask_with_field(:output_data_rate, ctrl_reg1.output_data_rate)
  end

  defp mask_with_field(int, :power_mode, :active), do: int ||| @power_mode_active
  defp mask_with_field(int, :block_data_update, :wait_for_reading), do: int ||| @wait_for_reading
  defp mask_with_field(int, :output_data_rate, :one_Hz), do: int ||| @one_Hz
  defp mask_with_field(int, :output_data_rate, :seven_Hz), do: int ||| @seven_Hz

  defp mask_with_field(int, :output_data_rate, :twelve_point_5_Hz),
    do: int ||| @twelve_point_five_Hz

  defp mask_with_field(int, _, field) when field in [:down, :continuous, :one_shot], do: int

  defimpl HTS221.Register do
    alias HTS221.{CTRLReg1, IORead, IOWrite}

    def read(_ctrl_reg1) do
      {:ok,
       %IORead{
         register: 0x20,
         length: 1
       }}
    end

    def write(ctrl_reg1) do
      binary = CTRLReg1.to_binary(ctrl_reg1)

      {:ok, IOWrite.new(binary)}
    end
  end
end
