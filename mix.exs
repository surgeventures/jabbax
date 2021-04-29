defmodule Jabbax.Mixfile do
  use Mix.Project

  def project do
    [
      app: :jabbax,
      version: "0.1.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:logger], env: [json_encoder: Poison, json_decoder: Poison]]
  end

  defp deps do
    [{:plug, "~> 1.3.2 or ~> 1.4", optional: true}, {:poison, "~> 3.0", optional: true}]
  end
end
