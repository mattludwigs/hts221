defmodule HTS221.AVConfTest do
  use ExUnit.Case, async: true

  alias HTS221.AVConf

  test "from binary" do
    byte = 0b0010_1011

    expected_conf = %AVConf{
      temperature_samples: 64,
      humidity_samples: 32
    }

    assert expected_conf == AVConf.from_binary(<<byte>>)
  end

  test "to binary" do
    byte = 0b00010111
    expected_binary = <<0x10, byte>>

    av_config = %AVConf{
      temperature_samples: 8,
      humidity_samples: 512
    }

    assert expected_binary == AVConf.to_binary(av_config)
  end
end
