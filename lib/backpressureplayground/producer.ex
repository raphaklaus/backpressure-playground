defmodule Backpressureplayground.Producer do
  use GenStage

  def start_link(initial \\ 0) do
    IO.inspect "node"
    IO.inspect node()
    GenStage.start_link(__MODULE__, initial, name: __MODULE__)
  end

  def init(_counter), do: {:producer, []}

  def add(), do: GenServer.cast(__MODULE__, {:add, 0..10 |> Enum.to_list()})

  def handle_cast({:add, events}, state) do
    # IO.inspect "add"
    # IO.inspect events
    # {:noreply, events, state} -> Add events directly to consumer
    # {:noreply, events, events} -> Add events to state, to later be demanded by consumer
    IO.inspect "adding this:"
    IO.inspect state
    {:noreply, events, events}
  end

  def handle_demand(demand, state) do
    # IO.inspect "demand"
    # IO.inspect demand
    # IO.inspect Enum.split(state, demand)
    IO.inspect "state"
    IO.inspect state
    # IO.inspect "demand"
    # IO.inspect demand
    case Enum.split(state, demand) do
      {events_to_be_sent, []} ->
        {:noreply, events_to_be_sent, []}
      {events_to_be_sent, remainings} ->
        {:noreply, events_to_be_sent, remainings}
    end
  end
end
