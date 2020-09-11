defmodule HTS221.AVConf do
  @moduledoc """
  Register for reading and writing the level temperature and humidity average

  By default the average is calculated off of 16 temperature samples and 32
  humidity samples.

  The more samples the less degree of error in the reading, however that also
  will cause the HTS221 to draw more power. Check the data sheet section 7.2
  for more information.
  """

  @type temperature_sample() :: 2 | 4 | 8 | 16 | 32 | 64 | 128 | 256

  @type humidity_sample() :: 4 | 8 | 16 | 32 | 64 | 128 | 256 | 512

  @type t() :: %__MODULE__{
          temperature_samples: temperature_sample(),
          humidity_samples: humidity_sample()
        }

  defstruct temperature_samples: 16, humidity_samples: 32

  def from_binary(<<_::size(2), temp::size(3), hum::size(3)>>) do
    %__MODULE__{
      temperature_samples: temp_samples_from_int(temp),
      humidity_samples: hum_samples_from_int(hum)
    }
  end

  @spec to_binary(t()) :: binary()
  def to_binary(av_conf) do
    tem_int = temp_samples_to_int(av_conf.temperature_samples)
    hum_int = hum_samples_to_int(av_conf.humidity_samples)

    payload = <<0::size(2), tem_int::size(3), hum_int::size(3)>>

    <<0x10>> <> payload
  end

  defp temp_samples_from_int(0), do: 2
  defp temp_samples_from_int(n), do: :math.pow(2, n + 1) |> round()

  defp hum_samples_from_int(n), do: :math.pow(2, n + 2) |> round()

  defp temp_samples_to_int(num_of_samples) do
    log = :math.log2(num_of_samples) - 1

    round(log)
  end

  defp hum_samples_to_int(num_of_samples) do
    log = :math.log2(num_of_samples) - 2

    round(log)
  end

  defimpl HTS221.Register do
    alias HTS221.{AVConf, IORead, IOWrite}

    def read(_av_config) do
      {:ok, IORead.new(0x10, 1)}
    end

    def write(av_config) do
      io_request =
        av_config
        |> AVConf.to_binary()
        |> IOWrite.new()

      {:ok, io_request}
    end
  end
end
