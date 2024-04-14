defmodule Codeowners.MixProject do
  use Mix.Project

  @source_url "https://github.com/reid-rigo/codeowners"
  @version "0.1.0"

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
      source_url: @source_url
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.32", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    A pure Elixir CODEOWNERS parser.
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
end
