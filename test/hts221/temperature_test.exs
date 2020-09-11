defmodule HTS221.TemperatureTest do
  use ExUnit.Case, async: true

  alias HTS221.Temperature

  test "from binary" do
    expected_temperature = %Temperature{
      temp_out_l: 0xAA,
      temp_out_h: 0x56,
      raw: 22186
    }

    assert expected_temperature == Temperature.from_binary(<<0xAA, 0x56>>)
  end
end
