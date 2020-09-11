defmodule HTS221Test do
  use ExUnit.Case, async: true

  alias HTS221.Calibration
  alias HTS221Test.Transport.Mock

  setup do
    {:ok, transport} = Mock.init([])

    calibration = %Calibration{
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

    {:ok, %{transport: transport, calibration: calibration}}
  end

  test "reads the calibration for the HTS221", %{transport: transport, calibration: calibration} do
    assert {:ok, calibration} == HTS221.read_calibration(transport)
  end
end
