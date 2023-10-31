defmodule UrlShortener.Link do
  use GenServer
  require Logger

  @hash_id_length 8

  defstruct url: "",
            host: "",
            shortened_url: "",
            partition_id: 0

  # start link

  def start_link(url, name) do
    GenServer.start_link(__MODULE__, url, name: String.to_atom(name))
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
    {:ok, %__MODULE__{ url: url, host: get_host_from_url(url), shortened_url: generate() }}
  end

  # callbacks

  def handle_call(:get_shortened_url, _from, %__MODULE__{ shortened_url: shortened_url } = state) do
    {:reply, shortened_url, state}
  end
  
  def handle_call(:get_partition_id, _from, %__MODULE__{ partition_id: partition_id } = state) do
    {:reply, partition_id, state}
  end

  def handle_call(:get_shortened_link, _from, %__MODULE__{ shortened_url: shortened_url } = state) do
    {:reply, "#{get_domain_basename()}/#{shortened_url}", state}
  end

  def handle_cast(:regenerate_shortened_url, state) do
    updated_state = %__MODULE__{ shortened_url: generate() }

    {:noreply, updated_state}
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
    config = Application.get_env(:iasc_shortener, Shortener.Domains)
    config[:basename]
  end

  @doc "Get host from url"
  def get_host_from_url(url) do
    url |> URI.parse() |> Map.fetch!(:host)
  end

  @doc "Generates a HashId"
  @spec generate() :: String.t
  def generate do
    @hash_id_length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64
    |> binary_part(0, @hash_id_length)
  end
end