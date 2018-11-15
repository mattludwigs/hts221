defmodule HTS221 do
  use GenServer

  import Bitwise
  alias Circuits.I2C
  alias HTS221.Calibration

  @type t :: pid

  @type scale :: :celsius | :fahrenheit | :kelvin

  @type temperature_opt :: {:scale, scale}

  def start_link(bus_name, opts \\ []) do
    GenServer.start_link(__MODULE__, bus_name, opts)
  end

  def start(bus_name, opts \\ []) do
    GenServer.start(__MODULE__, bus_name, opts)
  end

  @doc """
  Get the temperature from the sensor

  Options:

    * `:scale` - the reading scale either `:celsius`, `:fahrenheit`, or `:kelvin` (default `:celsius`)
  """
  @spec temperature(t, [temperature_opt]) :: integer
  def temperature(hts221, opts \\ [scale: :celsius]) do
    GenServer.call(hts221, {:temperature, opts})
  end

  @doc """
  Get the relative humidity percentage from the sensor
  """
  @spec humidity(t) :: integer
  def humidity(hts221) do
    GenServer.call(hts221, :humidity)
  end

  @doc """
  Read a register from the sensor. Takes a sensor pid, the register byte, and the number of bytes to read
  """
  @spec read_register(t, byte, pos_integer) :: {:ok, binary} | {:error, reason :: any}
  def read_register(hts221, register, bytes) do
    GenServer.call(hts221, {:read_register, register, bytes})
  end

  @doc """
  Write to a register.

  Takes a hts221 pid, a register byte, and the data to be written to that register
  """
  @spec write_register(t, byte, binary) :: :ok
  def write_register(hts221, register, data) do
    GenServer.call(hts221, {:write_register, register, data})
  end

  def init(bus) do
    with {:ok, bus} <- I2C.open(bus),
         :ok <- I2C.write(bus, 0x5F, <<0x20, 0x85>>),
         :ok <- I2C.write(bus, 0x5F, <<0x10, 0x1B>>),
         {:ok, calibration} <- I2C.write_read(bus, 0x5F, <<0x30 ||| 0x80>>, 16),
         {:ok, %Calibration{} = calibration} <- Calibration.from_binary(calibration) do
      state = %{
        bus: bus,
        calibration: calibration
      }

      {:ok, state}
    else
      error -> {:stop, error}
    end
  end

  def handle_call(
        {:temperature, opts},
        _from,
        %{
          bus: bus,
          calibration:
            %Calibration{
              t0_out: t0_out,
              t1_out: t1_out,
            } = calibration
        } = state
      ) do
    {:ok, <<t::signed-integer-little-size(2)-unit(8)>>} =
      I2C.write_read(bus, 0x5F, <<0x2A ||| 0x80>>, 2)

    t0 = Calibration.t0(calibration)
    t1 = Calibration.t1(calibration)

    temp = (t1 - t0) * (t - t0_out) / (t1_out - t0_out) + t0
    scale = Keyword.get(opts, :scale)

    {:reply, calc_temp(temp, scale), state}
  end

  def handle_call(
        :humidity,
        _from,
        %{
          bus: bus,
          calibration:
            %Calibration{
              h0_t0_out: h0_t0_out,
              h1_t0_out: h1_t0_out
            } = calibration
        } = state
      ) do
    {:ok, <<h::signed-integer-little-size(2)-unit(8)>>} =
      I2C.write_read(bus, 0x5F, <<0x28 ||| 0x80>>, 2)

    h0 = Calibration.h0(calibration)
    h1 = Calibration.h1(calibration)

    humidity = (h1 - h0) * (h - h0_t0_out) / (h1_t0_out - h0_t0_out) + h0

    {:reply, humidity, state}
  end

  def handle_call({:read_register, register, bytes}, _from, %{bus: bus} = state) do
    {:reply, I2C.write_read(bus, 0x5F, <<register>>, bytes), state}
  end

  def handle_call({:write_register, register, data}, _from, %{bus: bus} = state) do
    {:reply, I2C.write(bus, 0x5F, <<register>> <> data), state}
  end

  defp calc_temp(temp, :celsius), do: temp
  defp calc_temp(temp, :fahrenheit), do: temp * 1.8 + 32
  defp calc_temp(temp, :kelvin), do: temp + 273.15
end
