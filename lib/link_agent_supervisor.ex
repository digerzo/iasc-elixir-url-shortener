defmodule UrlShortener.Link.Agent.Supervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    children = [
      #%{id: StackAgent, start: {StackAgent, :start_link, [[], StackAgent]}},
      %{id: UrlShortenerAgent, start: {UrlShortener.Link.Agent, :start_link, [Agent1]}, restart: :transient},
    ]

    Supervisor.init(children, strategy: :one_for_one, max_restarts: 5, max_seconds: 5)
  end
end
