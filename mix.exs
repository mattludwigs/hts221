defmodule HTS221.MixProject do
  use Mix.Project

  @version "0.2.0"
  @source_url "https://github.com/mattludwigs/hts221"

  def project do
    [
      app: :hts221,
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      dialyzer: dialyzer(),
      elixirc_paths: elixirc_paths(Mix.env()),
      docs: docs(),
      description: description(),
      preferred_cli_env: [docs: :docs, "hex.publish": :docs]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.22", only: :docs, runtime: false},
      {:dialyxir, "~> 1.0.0", only: [:dev], runtime: false},
      {:circuits_i2c, "~> 0.3.6"}
    ]
  end

  defp package do
    [
      maintainers: ["Matt Ludwigs"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/mattludwigs/hts221"}
    ]
  end

  defp description() do
    "An Elixir library for working with the HTS221 sensor"
  end

  defp dialyzer() do
    [
      flags: [:race_conditions, :unmatched_returns, :error_handling]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp docs do
    [
      extras: ["README.md", "CHANGELOG.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
    ]
  end
end
