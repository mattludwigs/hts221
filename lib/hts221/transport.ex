defmodule HTS221.Transport do
  @moduledoc """
  A behaviour to communicate to the HTS221
  """

  alias HTS221.{IORead, IOWrite}

  import Bitwise

  @typedoc """
  Arguments for the implementation `init/1` callback

  See the implementation's docs to see what the arguments are.
  """
  @type arg() :: any()

  @typedoc """
  A module that implements the `HTS221.Transport` behaviour
  """
  @type impl() :: module()

  @typedoc """
  The underline communication data structure for the transport implementation
  to use when sending data to the HTS221.

  For example in `Circuits.I2C` the data structure is a reference.
  """
  @type comm() :: any()

  @type t() :: {impl(), comm()}

  @doc """
  Initialize the transport implementation
  """
  @callback init([arg()]) :: {:ok, t()} | {:error, any()}

  @doc """
  Read the register
  """
  @callback read_register(comm(), binary(), non_neg_integer()) ::
              {:ok, binary()} | {:error, any()}

  @doc """
  Write the register
  """
  @callback write_register(comm(), binary()) :: :ok | {:error, any()}

  @doc """
  Helper function initializing the transport implementation
  """
  @spec init(impl(), [arg()]) :: {:ok, t()} | {:error, any()}
  def init(impl, args \\ []) do
    impl.init(args)
  end

  @doc """
  Send the IO request to the HTS221
  """
  @spec send(t(), IORead.t() | IOWrite.t()) :: :ok | {:ok, binary()} | {:error, any()}
  def send({impl, comm}, %IORead{} = io_request) do
    binary = make_binary(io_request)

    impl.read_register(comm, binary, io_request.length)
  end

  def send({impl, comm}, %IOWrite{} = io_request) do
    impl.write_register(comm, io_request.payload)
  end

  defp make_binary(%IORead{length: n} = io_request) when n > 1 do
    # When we want to read many registers at once the MSB bit needs to be set to
    # 1.
    <<io_request.register ||| 0x80>>
  end

  defp make_binary(io_request) do
    <<io_request.register>>
  end
end
