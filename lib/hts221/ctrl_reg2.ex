defmodule HTS221.CTRLReg2 do
  @moduledoc """
  Control the memory boot, heater element, and one shot initialization for the
  HTS221
  """

  import Bitwise

  @reboot_memory 0x80
  @heater_enabled 0x02
  @one_shot_get_new_data_set 0x01

  @type boot_mode() :: :normal | :reboot_memory

  @type heater_mode() :: :disabled | :enabled

  @type one_shot() :: :waiting | :get_new_dataset

  @type t() :: %__MODULE__{
          boot: boot_mode(),
          heater: heater_mode(),
          one_shot: one_shot()
        }

  defstruct boot: :normal, heater: :disabled, one_shot: :waiting

  @doc """
  Parse a binary register response into the `HTS221.CTRLReg2` structure
  """
  @spec from_binary(binary()) :: t()
  def from_binary(
        <<boot_mode_bit::size(1), _::size(5), heater_bit::size(1), one_shot_bit::size(1)>>
      ) do
    %__MODULE__{
      boot: boot_mode_from_bit(boot_mode_bit),
      heater: heater_mode_from_bit(heater_bit),
      one_shot: one_shot_from_bit(one_shot_bit)
    }
  end

  @doc """
  Make a `HTS221.CTRLReg2` structure into a binary string to be written to the
  register
  """
  @spec to_binary(t()) :: binary()
  def to_binary(%__MODULE__{} = ctrl_reg2) do
    <<0x21, fields_to_mask(ctrl_reg2)>>
  end

  defp boot_mode_from_bit(0), do: :normal
  defp boot_mode_from_bit(1), do: :reboot_memory

  defp heater_mode_from_bit(0), do: :disabled
  defp heater_mode_from_bit(1), do: :enabled

  defp one_shot_from_bit(0), do: :waiting
  defp one_shot_from_bit(1), do: :get_new_dataset

  defp fields_to_mask(%__MODULE__{} = ctrl_reg2) do
    0
    |> mask_field(:boot, ctrl_reg2.boot)
    |> mask_field(:heater, ctrl_reg2.heater)
    |> mask_field(:one_shot, ctrl_reg2.one_shot)
  end

  defp mask_field(mask, _, value) when value in [:waiting, :disabled, :normal], do: mask

  defp mask_field(mask, :boot, :reboot_memory), do: mask ||| @reboot_memory
  defp mask_field(mask, :heater, :enabled), do: mask ||| @heater_enabled
  defp mask_field(mask, :one_shot, :get_new_dataset), do: mask ||| @one_shot_get_new_data_set

  defimpl HTS221.Register do
    alias HTS221.{CTRLReg2, IORead, IOWrite}

    def read(_) do
      {:ok, IORead.new(0x21, 1)}
    end

    def write(ctrl_reg2) do
      {:ok, IOWrite.new(CTRLReg2.to_binary(ctrl_reg2))}
    end
  end
end
