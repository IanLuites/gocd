defmodule GoCD.MixProject do
  use Mix.Project

  def project do
    [
      app: :gocd,
      version: "0.0.1",
      description: "A GoCD client library for Elixir.",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),

      # Testing
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      dialyzer: [ignore_warnings: ".dialyzer", plt_add_deps: true],

      # Docs
      name: "GoCD",
      source_url: "https://github.com/IanLuites/gocd",
      homepage_url: "https://github.com/IanLuites/gocd",
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  def package do
    [
      name: :gocd,
      maintainers: ["Ian Luites"],
      licenses: ["MIT"],
      files: [
        # Elixir
        "lib/gocd",
        "lib/gocd.ex",
        ".formatter.exs",
        "mix.exs",
        "README*",
        "LICENSE*"
      ],
      links: %{
        "GitHub" => "https://github.com/IanLuites/gocd"
      }
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:common_x, "~> 0.0.1"},
      {:httpx, "~> 0.0.16"},

      # Dev Only
      {:analyze, "~> 0.1.4", optional: true, runtime: false, only: [:dev, :test]},
      {:dialyxir, "~> 1.0.0-rc.6", optional: true, runtime: false, only: [:dev, :test]}
    ]
  end
end
