defmodule HTS221 do
  @moduledoc """
  Functions for working with the HTS221

  The functionality is useful for use cases where you need complete control
  over the sensor or to debug the registers. If you just want to get started
  quickly see `HTS221.Server` module.

  To read registers you will need to provide a `HTS221.Transport.t()`.

  ```
  {:ok, transport} = HTS221.Transport.init(HTS221.Transport.I2C, bus_name: "i2c-1")
  ```

  ## Reading Registers

  After opening the transport you can read or write registers.

  ```
  {:ok, %HTS221.Temperature{} = temp} = HTS221.read_temperature(transport)
  ```

  While this library provides some common helper functions to read particular
  registers it does not provide all the registers currently. However, the
  library does provide the `HTS221.Register` protocol and
  `HTS221.read_register/2` that will allow you to provide support for any
  register.

  ## Writing Registers

  To write a register you will need to use `HTS221.write_register/2`.

  ```
  # this will provide the default register values
  ctrl_reg1 = %HTS221.CTRLReg1{}

  HTS221.write_register(transport, ctrl_reg1)
  ```

  ## Calibration

  Each HTS221 is calibrated that the factory and the calibration that is stored
  in non-volatile memory is specific to each sensor. The calibration contains
  data about how to calculate the temperature and humidity and thus you will
  need to the calibration values to make those calculations.

  This library provides functionality for reading the calibration and using it
  to calculate the temperature and humidity.

  ```
  {:ok, %HTS221.Calibration{} = calibration} = HTS221.read_calibration(transport)

  {:ok, %HTS221.Temperature{} = temp} = HTS221.read_temperature(transport)

  temp_in_celsius = HTS221.calculate_temperature(temp, calibration)
  ```

  _the same steps are required for calculating humidity_
  """

  alias HTS221.{AVConf, Calibration, CTRLReg1, Humidity, Register, Temperature, Transport}

  @typedoc """
  Signed 16-bit integer
  """
  @type s16() :: -32_768..32_767

  @typedoc """
  The scale in which the temperature is calculated (default `:celsius`)
  """
  @type scale() :: :celsius | :fahrenheit | :kelvin

  @type opt() :: {:scale, scale()}

  @doc """
  Read the calibration on the HTS221

  This is useful for checking the calibration on the hardware itself or fetch
  the calibration after any other register initialization and storing it for
  future calculations.


  ```elixir
  {:ok, calibration} = HTS221.read_calibration(hts221)

  %HTS221{hts221 | calibration: calibration}
  ```
  """
  @spec read_calibration(Transport.t()) :: {:ok, Calibration.t()} | {:error, any()}
  def read_calibration(transport) do
    case read_register(transport, %Calibration{}) do
      {:ok, binary} ->
        {:ok, Calibration.from_binary(binary)}

      error ->
        error
    end
  end

  @doc """
  Read the `CTRL_REG1` register

  See the `HTS221.CTRLReg1` module for more information.
  """
  @spec read_ctrl_reg1(Transport.t()) :: {:ok, CTRLReg1.t()} | {:error, any()}
  def read_ctrl_reg1(transport) do
    case read_register(transport, %CTRLReg1{}) do
      {:ok, binary} ->
        {:ok, CTRLReg1.from_binary(binary)}

      error ->
        error
    end
  end

  @doc """
  Read the `AV_CONF` register

  See the `HTS221.AVConfig` module for more information.
  """
  @spec read_av_conf(Transport.t()) :: {:ok, AVConf.t()} | {:error, any()}
  def read_av_conf(transport) do
    case read_register(transport, %AVConf{}) do
      {:ok, binary} ->
        {:ok, AVConf.from_binary(binary)}

      error ->
        error
    end
  end

  @doc """
  Read the values of the temperature registers

  This function does not provide the final calculations of the temperature but
  only provides the functionality of reading the raw values in the register.
  """
  @spec read_temperature(Transport.t()) :: {:ok, Temperature.t()} | {:error, any()}
  def read_temperature(transport) do
    case read_register(transport, %Temperature{}) do
      {:ok, binary} ->
        {:ok, Temperature.from_binary(binary)}

      error ->
        error
    end
  end

  @doc """
  Read the values of the humidity registers

  This function does not provided the final calculations of the humidity but
  only provides the functionality of reading the raw values in the register.
  """
  @spec read_humidity(Transport.t()) :: {:ok, Humidity.t()} | {:error, any()}
  def read_humidity(transport) do
    case read_register(transport, %Humidity{}) do
      {:ok, binary} ->
        {:ok, Humidity.from_binary(binary)}

      error ->
        error
    end
  end

  @doc """
  Read any register that implements the `HTS221.Register` protocol
  """
  @spec read_register(Transport.t(), Register.t()) :: {:ok, binary()} | {:error, any()}
  def read_register(transport, register) do
    case Register.read(register) do
      {:ok, io_request} ->
        Transport.send(transport, io_request)

      error ->
        error
    end
  end

  @doc """
  Write any register that implements the `HTS221.Register` protocol
  """
  @spec write_register(Transport.t(), Register.t()) :: :ok | {:error, any()}
  def write_register(transport, register) do
    case Register.write(register) do
      {:ok, io_request} ->
        Transport.send(transport, io_request)

      error ->
        error
    end
  end

  @doc """
  Calculate the temperature from the `HTS221.Temperature` register values

  This requires the `HTS221.Calibration` has the the temperature register
  values are the raw reading from the ADC. Each HTS221 is calibrated during
  manufacturing and contains the coefficients to required to convert the ADC
  values into degrees celsius (default).
  """
  @spec calculate_temperature(Temperature.t(), Calibration.t(), [opt()]) :: float()
  def calculate_temperature(temperature, calibration, opts \\ []) do
    scale = Keyword.get(opts, :scale, :celsius)
    t0 = Calibration.t0(calibration)
    t1 = Calibration.t1(calibration)
    t = temperature.raw

    slope = (t1 - t0) / (calibration.t1_out - calibration.t0_out)
    offset = t0 - slope * calibration.t0_out

    calc_temp(
      slope * t + offset,
      scale
    )
  end

  @doc """
  Calculate the humidity from the `HTS221.Humidity` register values

  This requires the `HTS221.Calibration` has the the humidity register values
  are the raw reading from the ADC. Each HTS221 is calibrated during
  manufacturing and contains the coefficients to required to convert the ADC
  values into percent.
  """
  @spec calculate_humidity(Humidity.t(), Calibration.t()) :: float()
  def calculate_humidity(humidity, calibration) do
    h0 = Calibration.h0(calibration)
    h1 = Calibration.h1(calibration)
    h = humidity.raw

    slope = (h1 - h0) / (calibration.h1_t0_out - calibration.h0_t0_out)
    offset = h0 - slope * calibration.h0_t0_out

    slope * h + offset
  end

  defp calc_temp(temp, :celsius), do: temp
  defp calc_temp(temp, :fahrenheit), do: temp * 1.8 + 32
  defp calc_temp(temp, :kelvin), do: temp + 273.15
end
