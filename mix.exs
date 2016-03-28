defmodule Clicksign.Mixfile do
  use Mix.Project

  def project do
    [app: :clicksign,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [ 
      applications: [
        :logger, 
        :httpoison
      ]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:mix_test_watch, "~> 0.2.6", only: [:dev]},
      {:httpoison, "~> 0.8.2"},
      {:bypass, "~> 0.1"},
      {:cowboy, "~> 1.0"},
      {:plug, "~> 1.1"},
      {:exjsx, "~> 3.2"}
    ]
  end
end
