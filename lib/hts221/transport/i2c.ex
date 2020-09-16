defmodule HTS221.Transport.I2C do
  @moduledoc """
  I2C implementation of the `HTS221.Transport` behaviour

  Args:

    - `:bus_name` - the string of the I2C bus: `i2c-1`
  """

  @behaviour HTS221.Transport

  @address 0x5F

  alias Circuits.I2C

  @impl HTS221.Transport
  def init(args) do
    case Keyword.get(args, :bus_name) do
      nil ->
        {:error, :missing_bus_name}

      bus_name ->
        if device_available?(bus_name) do
          open_bus(bus_name)
        else
          {:error, :device_not_available}
        end
    end
  end

  @impl HTS221.Transport
  def read_register(bus, binary, length) do
    I2C.write_read(bus, @address, binary, length)
  end

  @impl HTS221.Transport
  def write_register(bus, binary) do
    I2C.write(bus, @address, binary)
  end

  defp device_available?(bus_name) do
    Enum.member?(I2C.detect_devices(bus_name), @address)
  end

  defp open_bus(bus_name) do
    case I2C.open(bus_name) do
      {:ok, bus} ->
        {:ok, {__MODULE__, bus}}

      error ->
        error
    end
  end
end
