defmodule Backpressureplayground.Consumer do
  use GenStage

  def start_link do
    IO.inspect "consumer start link"
    GenStage.start_link(__MODULE__, %{})
  end

  def init(state) do
    {:consumer, state, subscribe_to: [Backpressureplayground.Producer]}
  end

  def handle_subscribe(:producer, opts, from, producers) do
    # We will only allow max_demand events every 2000 milliseconds
    pending = opts[:max_demand] || 5
    interval = opts[:interval] || 2000

    # Register the producer in the state
    producers = Map.put(producers, from, {pending, interval})
    # Ask for the pending events and schedule the next time around
    producers = ask_and_schedule(producers, from)

    # Returns manual as we want control over the demand
    {:manual, producers}
  end

  def handle_cancel(_, from, producers) do
    # Remove the producers from the map on unsubscribe
    {:noreply, [], Map.delete(producers, from)}
  end

  def handle_info({:ask, from}, producers) do
    # This callback is invoked by the Process.send_after/3 message below.
    {:noreply, [], ask_and_schedule(producers, from)}
  end

  defp ask_and_schedule(producers, from) do
    case producers do
      %{^from => {pending, interval}} ->
        # IO.inspect "pending"
        # IO.inspect pending
        # Ask for any pending events
        GenStage.ask(from, pending)
        # And let's check again after interval
        Process.send_after(self(), {:ask, from}, interval)
        # Finally, reset pending events to 0
        Map.put(producers, from, {0, interval})
      %{} ->
        producers
    end
  end

  @spec handle_events(any, any, any) :: {:noreply, [], any}
  def handle_events(events, _from, producers) do
    # Bump the amount of pending events for the given producer
    IO.inspect "handle_events"
    IO.inspect events

    #producers = Map.update!(producers, from, fn {pending, interval} ->
      # IO.inspect "events-loop"
      # IO.inspect events
      #{pending + length(events), interval}
    #end)

    # Consume the events by printing them.
    # IO.inspect(events)
    # IO.inspect producers

    # A producer_consumer would return the processed events here.
    {:noreply, [], producers}
  end
end
