defmodule Backpressureplayground.Producer do
  use GenStage

  def start_link(initial \\ 0) do
    GenStage.start_link(__MODULE__, initial, name: __MODULE__)
  end

  def init(_counter), do: {:producer, %{events: []}}

  def add(), do: GenServer.cast(__MODULE__, {:add, Enum.to_list(0..10)})

  def handle_cast({:add, events}, state) do
    # IO.inspect "add"
    # IO.inspect events
    # {:noreply, events, state} -> Add events directly to consumer
    # {:noreply, events, events} -> Add events to state, to later be demanded by consumer
    IO.puts("producer events: #{inspect(events)}")

    {:noreply, events, %{events: events}}
  end

  def handle_demand(demand, %{events: events}) do
    {to_send_events, remain_evens} = Enum.split(events, demand)
    IO.puts("producer remaining events: #{inspect(remain_evens)}")
    {:noreply, to_send_events, %{events: remain_evens}}
  end
end
