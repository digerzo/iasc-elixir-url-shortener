defmodule UrlShortener.Link do
  use GenServer
  require Logger

  @hash_id_length 8

  defstruct url: "",
            host: "",
            shortened_url: ""
  # start link

  def start_link(url, name) do
    GenServer.start_link(__MODULE__, url)
  end

  def child_spec({name, url}) do
    %{
      id: name,
      start: {__MODULE__, :start_link, [url, name]},
      type: :worker,
      restart: :transient
    }
  end

  def init(url) do
    Process.flag(:trap_exit, true)

    Logger.info("Process created... Url to be shortened: #{url}")

    # Set initial state and return from `init`
    {:ok, %__MODULE__{ url: url, host: get_host_from_url(url) }}
  end

  # callbacks
  def handle_call(:get_shortened_link, _from, %__MODULE__{ shortened_url: shortened_url } = state) do

    {:reply, "#{get_domain_basename()}/#{shortened_url}", state}
  end

  def handle_cast(:generate_shortened_link, %__MODULE__{ url: url } = state) do
    shortened = generate()
    UrlShortener.Link.Agent.guardar_link(Agent1, url, shortened)

    updated_state = state |> Map.put(:shortened_url, shortened)

    {:noreply, updated_state}
  end

  def handle_cast(:regenerate_shortened_url, state) do
    updated_state = %__MODULE__{ shortened_url: generate() }

    {:noreply, updated_state}
  end

  @doc "
   Client function to return a shorten_link
  "
  def get_shorten_link(pid) do
    GenServer.call(pid, :get_shortened_link)
  end

  @doc """
   Gracefully end this process
  """
  def handle_info(:end_process, state) do
    Logger.info("Process terminating... url: #{state.url}")
    {:stop, :normal, state}
  end

  # Other functions

  def get_domain_basename do
    "https://localhost"
  end

  @doc "Get host from url"
  def get_host_from_url(url) do
    url |> URI.parse() |> Map.fetch!(:host)
  end

  @doc "Generates a HashId"
  # No tocar
  @spec generate() :: String.t
  def generate do
    @hash_id_length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64
    |> binary_part(0, @hash_id_length)
  end
end
