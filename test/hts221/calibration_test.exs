defmodule HTS221.Calibration.Test do
  use ExUnit.Case, async: true

  alias HTS221.Calibration

  test "parses binary correctly" do
    calibration_binary = <<64, 144, 159, 10, 0, 196, 238, 255, 4, 4, 197, 201, 254, 255, 179, 2>>

    expected_calibration = %Calibration{
      h0_rh_x2: 64,
      h1_rh_x2: 144,
      t0_degc_x8: 159,
      t1_degc_x8: 10,
      t1_msb: 1,
      t0_msb: 0,
      h0_t0_out: -18,
      h1_t0_out: -13883,
      t0_out: -2,
      t1_out: 691
    }

    assert {:ok, expected_calibration} == Calibration.from_binary(calibration_binary)
  end

  test "gets the t0 value" do
    calibration_binary = <<64, 144, 159, 10, 0, 196, 238, 255, 4, 4, 197, 201, 254, 255, 179, 2>>
    {:ok, calibration} = Calibration.from_binary(calibration_binary)
    assert 19.875 == Calibration.t0(calibration)
  end

  test "gets the t1 value" do
    calibration_binary = <<64, 144, 159, 10, 0, 196, 238, 255, 4, 4, 197, 201, 254, 255, 179, 2>>
    {:ok, calibration} = Calibration.from_binary(calibration_binary)
    assert 33.25 == Calibration.t1(calibration)
  end

  test "gets the h0 value" do
    calibration_binary = <<64, 144, 159, 10, 0, 196, 238, 255, 4, 4, 197, 201, 254, 255, 179, 2>>
    {:ok, calibration} = Calibration.from_binary(calibration_binary)

    assert 32 == Calibration.h0(calibration)
  end

  test "gets the h1 value" do
    calibration_binary = <<64, 144, 159, 10, 0, 196, 238, 255, 4, 4, 197, 201, 254, 255, 179, 2>>
    {:ok, calibration} = Calibration.from_binary(calibration_binary)

    assert 72 == Calibration.h1(calibration)
  end
end
