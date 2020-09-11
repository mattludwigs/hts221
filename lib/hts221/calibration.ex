defmodule HTS221.Calibration do
  @moduledoc """
  The calibration for the HTS221

  Each HTS221 is calibrated at the factory and has an unique calibration. The
  calibration is used to calculate the temperature and humidity values that are
  stored in the registers as those values are raw ADC values.
  """

  import Bitwise

  @type t() :: %__MODULE__{
          t0_degc_x8: byte(),
          t1_degc_x8: byte(),
          t0_msb: byte(),
          t0_out: HTS221.s16(),
          t1_msb: byte(),
          t1_out: HTS221.s16(),
          h0_rh_x2: byte(),
          h0_t0_out: HTS221.s16(),
          h1_rh_x2: byte(),
          h1_t0_out: HTS221.s16()
        }

  defstruct [
    :t0_degc_x8,
    :t1_degc_x8,
    :t0_msb,
    :t0_out,
    :t1_msb,
    :t1_out,
    :h0_rh_x2,
    :h0_t0_out,
    :h1_rh_x2,
    :h1_t0_out
  ]

  def from_binary(
        <<h0_rh_x2, h1_rh_x2, t0_degc_x8, t1_degc_x8, _, _::size(4), t1_msb::size(2),
          t0_msb::size(2), h0_t0_out::signed-little-integer-size(2)-unit(8), _::binary-size(2),
          h1_t0_out::signed-little-integer-size(2)-unit(8),
          t0_out::signed-little-integer-size(2)-unit(8),
          t1_out::signed-little-integer-size(2)-unit(8)>>
      ) do
    calibration = %__MODULE__{
      t0_degc_x8: t0_degc_x8,
      t1_degc_x8: t1_degc_x8,
      t0_msb: t0_msb,
      t0_out: t0_out,
      t1_msb: t1_msb,
      t1_out: t1_out,
      h0_rh_x2: h0_rh_x2,
      h0_t0_out: h0_t0_out,
      h1_rh_x2: h1_rh_x2,
      h1_t0_out: h1_t0_out
    }

    calibration
  end

  def t0(%__MODULE__{t0_msb: t0_msb, t0_degc_x8: t0_degc_x8}) do
    ((t0_msb <<< 8) + t0_degc_x8) / 8
  end

  def t1(%__MODULE__{t1_msb: t1_msb, t1_degc_x8: t1_degc_x8}) do
    ((t1_msb <<< 8) + t1_degc_x8) / 8
  end

  def h0(%__MODULE__{h0_rh_x2: h0_rh_x2}) do
    h0_rh_x2 / 2
  end

  def h1(%__MODULE__{h1_rh_x2: h1_rh_x2}) do
    h1_rh_x2 / 2
  end

  defimpl HTS221.Register do
    alias HTS221.IORead

    def read(_calibration) do
      {:ok, IORead.new(0x30, 16)}
    end

    def write(_calibration) do
      {:error, :access_error}
    end
  end
end
