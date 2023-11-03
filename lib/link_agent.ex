defmodule UrlShortener.Link.Agent do
  use Agent
    @doc """
  Starts a new bucket.
  """
  def start_link(name) do
    Agent.start_link(fn -> %{} end, name: name)
  end

  @doc """
  Gets a value from the `links` by `key`.
  """
  def get(links, key) do
    Agent.get(links, &Map.get(&1, key))
  end

  @doc """
  Puts the `value` for the given `key` in the `links`.
  """
  def put(links, key, value) do
    Agent.update(links, &Map.put(&1, key, value))
  end

  def guardar_link(agent, dominio, shortened_url) do
    lista = Agent.get(agent, &Map.get(&1, dominio))
    if lista == nil do
      Agent.update(agent, &Map.put(&1, dominio, [shortened_url]))
    else
      Agent.update(agent, &Map.put(&1, dominio, lista ++ [shortened_url]))
    end
  end
end
