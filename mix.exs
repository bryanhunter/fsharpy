defmodule FsharpEx.Mixfile do
  use Mix.Project

  def project do
    [app: :fsharp_ex,
     version: "0.1.0",
     elixir: "~> 1.3",
     name: "FsharpEx",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:credo, "~> 0.5", only: :dev}
    ]
  end
end
