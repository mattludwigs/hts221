defmodule HTS221.CTRLReg1Test do
  use ExUnit.Case, async: true

  alias HTS221.CTRLReg1

  test "to binary" do
    ctrl_reg1 = %CTRLReg1{
      power_mode: :active,
      block_data_update: :wait_for_reading,
      output_data_rate: :one_Hz
    }

    byte = 0b10000101

    expected_binary = <<0x20, byte>>

    assert expected_binary == CTRLReg1.to_binary(ctrl_reg1)
  end

  test "from binary" do
    byte = 0b00000111

    expected_ctrl_reg1 = %CTRLReg1{
      power_mode: :down,
      block_data_update: :wait_for_reading,
      output_data_rate: :twelve_point_five_Hz
    }

    assert expected_ctrl_reg1 == CTRLReg1.from_binary(<<byte>>)
  end
end
