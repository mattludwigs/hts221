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
    with bus_name when is_binary(bus_name) <-
           Keyword.get(args, :bus_name, {:error, :missing_bus_name}),
         {:ok, bus} <- I2C.open(bus_name) do
      {:ok, {__MODULE__, bus}}
    else
      error -> error
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
end
