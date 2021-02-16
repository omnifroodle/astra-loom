defmodule Loom.MixProject do
  use Mix.Project

  def project do
    [
      app: :loom,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Loom.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon, :crypto]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.5.4"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.14.2"},
      {:phoenix_live_dashboard, "~> 0.1"},
      {:assent, "~> 0.1.13"},
      {:certifi, "~> 2.4"},
      {:ssl_verify_fun, "~> 1.1"},
      {:telemetry_poller, "~> 0.4"},
      {:telemetry_metrics, "~> 0.4"},
      {:floki, ">= 0.0.0", only: :test},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.1"},
      {:httpoison, "~> 1.7"},
      {:elixir_uuid, "~> 1.2"},
      {:guardian, "~> 2.0"},
      {:guardian_phoenix, "~> 2.0"},
      {:html_sanitize_ex, "~> 1.3.0-rc3"},
      {:astra, "~> 0.3"},
      {:poison, "~> 4.0"}
    ]
  end
end
