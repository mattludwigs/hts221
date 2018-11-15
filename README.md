# HTS221

[![CircleCI](https://circleci.com/gh/mattludwigs/hts221.svg?style=svg)](https://circleci.com/gh/mattludwigs/hts221)

An Elixir library for working with the HTS221 sensor via the I2C protocol. This sensor reports relative humidity
and temperature.

For more information about the HTS221 sensor please see the resources section below.

## Installation

The package can be installed by adding `hts221` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:hts221, "~> 0.1.0"}
  ]
end
```

## Usage

```elixir
iex> {:ok, hts221} = HTS221.start_link("i2c-1")
{:ok, #PID<0.1483.0>}
iex> HTS221.temperature(hts221)
25.68434423443
iex> HTS221.humidity(hts221)
34.44044343034
```  

We have to pass the I2C bus name into the `HTS221.start/2` and `HTS221.start_link/2`
functions to connect to the HTS221. See [Elixir Circuits I2C package](https://github.com/elixir-circuits/circuits_i2c)
for more information about using I2C with Elixir.

By default the temperature is read in degrees Celsius. However, we can change the
scale that is return by passing the `:scale` option to the `HTS221.temperature/2` function
like:

```elixir
iex> HTS221.temperature(hts221, scale: :fahrenheit)
77.415
```

## Resources 

 - [HTS221 datasheet](https://www.st.com/resource/en/datasheet/hts221.pdf)
 - [Interpreting humidity and temperature readings](https://www.st.com/resource/en/technical_note/dm00208001.pdf)

