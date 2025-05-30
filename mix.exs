defmodule Codeowners.MixProject do
  use Mix.Project

  @source_url "https://github.com/reid-rigo/codeowners"
  @version "0.2.1"

  def project do
    [
      app: :codeowners,
      version: @version,
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "Codeowners",
      source_url: @source_url,
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:benchee, "~> 1.4", only: :dev},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.38", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    A pure Elixir parser for the GitHub CODEOWNERS specification.
    """
  end

  defp package do
    [
      name: "codeowners",
      files: ~w(lib mix.exs README.md CHANGELOG.md LICENSE),
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      main: "Codeowners",
      extras: ["README.md"]
    ]
  end
end
