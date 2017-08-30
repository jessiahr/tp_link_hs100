defmodule TpLinkHs100.Mixfile do
  use Mix.Project

  def project do
    [
      app: :tp_link_hs100,
      version: "0.1.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      source_url: "https://github.com/jessiahr/map_diff",
      name: "tp_link_hs100"
   ]
  end

  defp description do
    """
    Control tp-link hs100 outlets using elixir.
    """
  end

  defp package do
    # These are the default files included in the package
    [
      name: :tp_link_hs100,
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Jessiah Ratliff"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/jessiahr/tp_link_hs100"}
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger],
     mod: {TpLinkHs100.Application, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:poison, "~> 3.0"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
