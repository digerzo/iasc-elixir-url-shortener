defmodule UrlShortener.LinkDynamicSupervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one, max_restarts: 4, max_seconds: 5)
  end

  def start_child(child_name, url) do
    #Ejemplo para agregar stack:
    #{:ok, pid} = UrlShortener.LinkDynamicSupervisor.start_child(ExmpleComAftermath, "https://example.com/aftermath.html")
    spec = {UrlShortener.Link, {child_name, url} }
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  # UrlShortener.LinkDynamicSupervisor.create_link("https://example.com/aftermath.html")
  def create_link(url) do
    start_child(extract(url),url)
  end

  # No tocar
  def extract(url) do
    sliced_url = Enum.slice(String.split(url, "/"), 2..-1)
    Enum.flat_map(sliced_url, fn k -> String.split(k, ".") |> Enum.take(1) end) |>
    Enum.reduce(fn s, acc -> "#{acc}_#{s}" end)
  end
end
