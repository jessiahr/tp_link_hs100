defmodule TpLinkHs100.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [
      worker(TpLinkHs100, []),
    ]

    opts = [strategy: :one_for_one, name: TpLinkHs100.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
