# Changelog

## v1.1.0 [2024-1-24]

- Loosen dependency requirements to allow for circuits_i2c v2

## v1.0.1 [2022-1-12]

- Bump to `1.0.0` and bump dependencies to latest.
- Drop support for Elixir < 1.11

## v0.2.1 [2020-9-16]

### Changed

- When running the `HTS221.Server` it would crash on start when the HTS221
  sensor was not on the bus. This is an issue when a device my optionally
  have the sensor. Now it shutdown gracefully and log that the HTS221 sensor
  was not found on the bus.

## v0.2.0

This is a complete rewrite. Please read README and moduledocs for new API

## v0.1.1

Updates `circuits_i2c` to prevent bugs in non nerves environments

## v0.1.0

Initial release!
