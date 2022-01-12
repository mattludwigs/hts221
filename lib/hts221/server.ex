defmodule HTS221.Server do
  @moduledoc """
  Server for setting up and using the HTS221

  When controlling the HTS221 there are few setup steps and other checks you
  may want to do. Also, to keep the transport layer working often times this
  will call for a GenServer. This server is meant to provide common
  functionality around setup and an expose a higher level API for application
  use.

  This process can be added to your supervision tree.

  ```
  def MyApp do
    use Application

    def start(_type, _args) do
      children = [
        ... children ...
        {HTS221.Server, transport: {HTS221.Transport.I2C, [bus_name: "i2c-1"]}
        ... children ...
      ]

      opts = [strategy: :one_for_one, name: MyApp.Supervisor]
      Supervisor.start(children, opts)
    end
  end
  ```

  If you a custom transport implementation then the `:transport` argument to
  this server will look different.

  If the HTS221 is not detected this server will log that it was not found and
  return `:ignore` on the `GenServer.init/1` callback. This is useful if your FW
  will run on devices with different hardware attached and don't want the device
  availability to crash your application supervisor.
  """

  use GenServer

  require Logger

  alias HTS221.{CTRLReg1, CTRLReg2, Transport}

  defmodule State do
    @moduledoc false

    alias HTS221.{Calibration, Transport}

    @type t() :: %__MODULE__{
            calibration: Calibration.t(),
            transport: Transport.t()
          }

    defstruct calibration: nil, transport: nil
  end

  @type name() :: any()

  @typedoc """
  Arguments to the `HTS221.Server`

    - `:transport` - the transport implementation module and optional arguments
    - `:name` - this is a named GenServer that either uses what you pass in or
      `HTS221.Server`
  """
  @type arg() ::
          {:transport, Transport.impl() | {Transport.impl(), [Transport.arg()]}} | {:name, name()}

  @type temperature_opt() :: {:scale, HTS221.scale()}

  @spec start_link([arg()]) :: GenServer.on_start()
  def start_link(args) do
    name = Keyword.get(args, :name, __MODULE__)
    GenServer.start_link(__MODULE__, args, name: name)
  end

  @doc """
  Read the temperature value

  By default this is read in celsius you can the `:scale` option to change the
  unit the temperature is measured in. See `HTS221.scale()` for more
  information.
  """
  @spec temperature(name(), [temperature_opt()]) :: {:ok, float()} | {:error, any()}
  def temperature(server, opts \\ []) do
    GenServer.call(server, {:temperature, opts})
  end

  @doc """
  Read the humidity level

  This is measured in percent.
  """
  @spec humidity(name()) :: {:ok, float()} | {:error, any()}
  def humidity(server) do
    GenServer.call(server, :humidity)
  end

  @doc """
  Get the transport the server is using

  This is useful if you need to debug the registers using the functions in
  `HTS221` module.
  """
  @spec transport(name()) :: Transport.t()
  def transport(server) do
    GenServer.call(server, :transport)
  end

  @impl GenServer
  def init(args) do
    {transport_impl, transport_args} = get_transport(args)

    with {:ok, transport} <- Transport.init(transport_impl, transport_args),
         :ok = reboot_registers(transport),
         {:ok, calibration} <- HTS221.read_calibration(transport),
         :ok <- setup_ctrl_reg1(transport) do
      {:ok, %State{calibration: calibration, transport: transport}}
    else
      {:error, :device_not_available} ->
        Logger.info("HTS221 not detected on device")
        :ignore

      error ->
        {:stop, error}
    end
  end

  @impl GenServer
  def handle_call({:temperature, opts}, _from, state) do
    %State{calibration: calibration, transport: transport} = state

    case HTS221.read_temperature(transport) do
      {:ok, temp} ->
        {:reply, {:ok, HTS221.calculate_temperature(temp, calibration, opts)}, state}

      error ->
        {:reply, error, state}
    end
  end

  def handle_call(:humidity, _from, state) do
    %State{calibration: calibration, transport: transport} = state

    case HTS221.read_humidity(transport) do
      {:ok, hum} ->
        {:reply, {:ok, HTS221.calculate_humidity(hum, calibration)}, state}

      error ->
        {:reply, error, state}
    end
  end

  def handle_call(:transport, _from, state) do
    {:reply, state.transport, state}
  end

  defp get_transport(args) do
    case Keyword.fetch!(args, :transport) do
      {_, _} = transport -> transport
      transport when is_atom(transport) -> {transport, []}
    end
  end

  defp reboot_registers(transport) do
    # Sometimes registers need to be rebooted to ensure
    # calibration is correctly being read from the non-volatile
    # memory.

    ctrl_reg2 = %CTRLReg2{
      boot: :reboot_memory
    }

    HTS221.write_register(transport, ctrl_reg2)
  end

  defp setup_ctrl_reg1(transport) do
    # setup HTS221 to continuously read datasets
    ctrl_reg1 = %CTRLReg1{
      power_mode: :active,
      block_data_update: :wait_for_reading,
      output_data_rate: :one_Hz
    }

    HTS221.write_register(transport, ctrl_reg1)
  end
end
