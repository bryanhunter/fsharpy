defmodule Fsharpy.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [app: :fsharpy,
      version: @version,
      elixir: "~> 1.3",
      deps: deps(),
      name: "Fsharpy",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      docs: [source_ref: "v#{@version}", main: "readme", extras: ["README.md"]],
      description: description(),
      package: package()]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:credo, "~> 0.5", only: :dev}
    ]
  end

  defp description do
    """
    Provides access to F# interactive (FSI) from Elixir. This is still in early stages
    so please just use it for fun until v1.0.0.
   """
  end

  defp package do
    [
     name: :fsharpy,
     files: ["lib", "priv", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
     maintainers: ["Bryan Hunter"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/bryanhunter/fsharpy"}
    ]
  end

end
