defmodule UrlShortener.Application do
# See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      UrlShortener.HordeRegistry, # horde registry
      # https://hexdocs.pm/horde/Horde.UniformQuorumDistribution.html
      {UrlShortener.HordeSupervisor, [strategy: :one_for_one, distribution_strategy: Horde.UniformQuorumDistribution, process_redistribution: :active]},
      UrlShortener.NodeObserver.Supervisor, # node supervisor. Not from Horde
      %{id: LinkDynamicSupervisor, start: {UrlShortener.LinkDynamicSupervisor, :start_link, [[]]} },
      %{id: AgentStaticSupervisor, start: {UrlShortener.Link.Agent.Supervisor, :start_link, [[]]} },
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html for other strategies and supported options
    opts = [strategy: :one_for_one, name: UrlShortener.GeneralSupervisor]
    Supervisor.start_link(children, opts)
  end

  defp topologies do
  end
end
