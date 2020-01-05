defmodule Backpressureplayground.Producer do
  use GenStage

  def start_link(initial \\ 0) do
    IO.inspect "node"
    IO.inspect node()
    GenStage.start_link(__MODULE__, initial, name: __MODULE__)
  end

  def init(_counter), do: {:producer, []}


  def add(:start), do: GenServer.cast(__MODULE__, {:add, 0..20 |> Enum.to_list()})

  def add(:end), do: GenServer.cast(__MODULE__, {:add, 888..950 |> Enum.to_list()})

  def handle_cast({:add, events}, state) do
    # IO.inspect "add"
    # IO.inspect events
    # {:noreply, events, state} -> Add events directly to consumer
    # {:noreply, events, events} -> Add events to state, to later be demanded by consumer
    IO.inspect "adding this:"
    IO.inspect events
    {:noreply, [], state ++ events}
  end

  def handle_demand(demand, state) do
    # IO.inspect "demand"
    # IO.inspect demand
    # IO.inspect Enum.split(state, demand)
    IO.inspect "state in producer"
    IO.inspect state, charlists: :as_lists
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
