defmodule FfSwitcher.MixProject do
  use Mix.Project

  def project do
    [
      app: :ff_switcher,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :yamerl]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:yamerl, github: "yakaz/yamerl"}
    ]
  end

  defp escript do
    [main_module: FfSwitcher]
  end
end
