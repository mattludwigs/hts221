# HTS221

[![CircleCI](https://circleci.com/gh/mattludwigs/hts221.svg?style=svg)](https://circleci.com/gh/mattludwigs/hts221)

An Elixir library for working with the HTS221 sensor. This sensor reports
relative humidity and temperature.

For more information about the HTS221 sensor please see the resources section below.

## Installation

The package can be installed by adding `hts221` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:hts221, "~> 0.2.1"}
  ]
end
```

## Usage

### Quick Start

This is assuming the HTS221 is using I2C.

```elixir
{:ok, _pid} = HTS221.Server.start_link(transport: {HTS221.Transport.I2C, [bus_name: "i2c-1"]})

temp = HTS221.Server.temperature(HTS221.Server)

hum  = HTS221.Server.humidity(HTS221.Server)
```

### Transports

To use the HTS221 you will need to provide a module that implements the
`HTS221.Transport` behaviour. This library provides the
`HTS221.Transport.I2C` module if you are using the HTS221 in I2C mode.

```elixir
{:ok, transport} = HTS221.Transport.init(HTS221.Transport.I2C, bus_name: "i2c-1")
```

### Calibration

The HTS221 calibration contains read-only data about the coefficients for
calculating the temperature in celsius and the humidity in percent. These values
are calibrated at the factory for each HTS221 sensor, so they are unique to each
sensor. In order to calcuate the temperature and the humidity you will need to
read the calibration and use that with the `HTS221.calculate_temperature/2` and
`HTS221.calculate_humidity/2` functions.

To read the calibration use the `HTS221.read_calibration/1` function:

```elixir
{:ok, %HTS221.Calibration{} = calibration} = HTS221.read_calibration(transport)
```

### Power Mode

By default the HTS221 is in "power-down" mode, which means the sensor will not 
any new readings. In order to enable the sensor to take new readings you can set
the `HTS221.CTRLReg1` register to use `:active` for its power mode.

```elixir
ctrl_reg1 = %HTS221.CTRLReg1{
  power_mode: :active
}

:ok = HTS221.write_register(transport, ctrl_reg1)
```

However, by default the sensor's output data rate (ORD) is set to `:one_shot`.
This means that you will need to trigger a new reading via the `CTRL_REG2`. If
you want the sensor to read without needing to trigger a new reading you can set
the `CTRL_REG2` up like this:

```elixir
ctrl_reg1 = %HTS221.CTRLReg1{
  power_mode: :active,
  output_data_rate: :one_Hz
}

:ok = HTS221.write_register(transport, ctrl_reg1)
```

For best data consistency though you will want to set the `:block_data_update`
field to `:wait_for_reading`. The recommend base `CTRL_REG1` configuration
should look like:

```elixir
ctrl_reg1 = %HTS221.CTRLReg1{
  power_mode: :active,
  output_data_rate: :one_Hz,
  block_data_update: :wait_for_reading
}

:ok = HTS221.write_register(transport, ctrl_reg1)
```

### Read and Calculate Temperature

```elixir
{:ok, %HTS221.Calibration{} = calibration} = HTS221.read_calibration(transport)
{:ok, %HTS221.Temperature{} = temp} = HTS221.read_temperature(transport)

HTS221.calculate_temperature(temp, calibration)

```

### Read and Calculate Humidity

```elixir
{:ok, %HTS221.Calibration{} = calibration} = HTS221.read_calibration(transport)
{:ok, %HTS221.Humidity{} = hum} = HTS221.read_humidity(transport)

HTS221.calculate_temperature(hum, calibration)

```

## Resources 

### Docs

- [HTS221 datasheet](https://www.st.com/resource/en/datasheet/hts221.pdf)
- [Interpreting humidity and temperature readings](https://www.st.com/resource/en/technical_note/dm00208001.pdf)


### Recommended Hardware

The hardware below is what I have used to develop, however this should would with
any supported hardware that [Nerves](https://hexdocs.pm/nerves/targets.html#supported-targets-and-systems) supports.

- [PMOD HTS221](https://store.alliedcomponentworks.com/collections/open-hardware/products/pmod-humidity-and-temperature-stmicroelectronics-hts221)
- [Raspberry PI PMOD Hat](https://store.alliedcomponentworks.com/collections/open-hardware/products/pmod-adapter-for-raspberry-pi-3)
- [Raspberry PI zero](https://www.adafruit.com/product/3708)

