defmodule Jabbax.Mixfile do
  use Mix.Project

  def project do
    [
      app: :jabbax,
      version: "0.1.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "JSON API Building Blocks Assembly for Elixir",
      source_url: "https://github.com/surgeventures/jabbax",
      homepage_url: "https://github.com/surgeventures/jabbax",
      package: package()
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/surgeventures/jabbax",
        "Fresha" => "https://www.fresha.com"
      },
      files: ~w(mix.exs lib LICENSE README.md)
    ]
  end

  def application do
    [extra_applications: [:logger], env: [json_encoder: Poison, json_decoder: Poison]]
  end

  defp deps do
    [
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:plug, "~> 1.3.2 or ~> 1.4", optional: true},
      {:poison, "~> 3.0", optional: true}
    ]
  end
end
