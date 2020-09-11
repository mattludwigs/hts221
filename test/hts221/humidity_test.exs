defmodule HTS221.HumidityTest do
  use ExUnit.Case, async: true

  alias HTS221.Humidity

  test "from binary" do
    expected_humidity = %Humidity{
      humidity_out_h: 0x03,
      humidity_out_l: 0xFF,
      raw: 1023
    }

    assert expected_humidity == Humidity.from_binary(<<0xFF, 0x03>>)
  end
end
