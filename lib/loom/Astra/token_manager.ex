defmodule Loom.Astra.TokenManager do
  use GenServer
  @update_interval 1_700_000

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_token() do
    GenServer.call(__MODULE__, {:get})
  end

  @impl true
  def init(:ok) do
    Process.send_after(self(), :tick, 1_700_000)
    {:ok, Loom.Astra.Actions.get_token()}
  end

  @impl true
  def handle_call({:get}, _, token) do
    {:reply, token, token}
  end

  @impl true
  def handle_cast({:set, new_token}, _token) do
    {:noreply, new_token}
  end

  @impl true
  def handle_info(:tick, _) do
    token = Loom.Astra.Actions.get_token
    Process.send_after(self(), :tick, @update_interval)
    {:noreply, token}
  end

end
