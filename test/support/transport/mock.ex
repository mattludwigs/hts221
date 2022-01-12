defmodule HTS221Test.Transport.Mock do
  @moduledoc false

  # Testing transport

  @behaviour HTS221.Transport

  @impl HTS221.Transport
  def init(_args) do
    {:ok, {__MODULE__, nil}}
  end

  @impl HTS221.Transport
  def read_register(_comm, <<register>>, 1) do
    {:ok, handle_read_register(register)}
  end

  def read_register(_comm, <<1::size(1), register::size(7)>>, _length) do
    {:ok, handle_read_register(register)}
  end

  @impl HTS221.Transport
  def write_register(_comm, _binary) do
    :ok
  end

  defp handle_read_register(0x30) do
    <<64, 144, 159, 10, 0, 196, 238, 255, 4, 4, 197, 201, 254, 255, 179, 2>>
  end
end
