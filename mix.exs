defmodule YandexDisk.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :yandex_disk,
      version: @version,
      elixir: "~> 1.8",
      description: description(),
      start_permanent: Mix.env() == :prod,
      source_url: "https://github.com/artemk/yandex_disk",
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    "Elixir Yandex Disk client"
  end

  defp package do
    [
      maintainers: ["Artem Kramarenko"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/artemk/yandex_disk"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.2.1"},
      {:elixir_uuid, "~> 1.2" },
      {:jason, "~> 1.1"},
      {:httpoison, "~> 1.4"},
      {:downstream, "~> 1.0.0"},
      {:bypass, "~> 1.0", only: :test},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end
end
