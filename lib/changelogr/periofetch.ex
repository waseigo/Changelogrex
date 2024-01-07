defmodule Periofetch do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> %{:last_check_time => :os.system_time(:millisecond)} end,
      name: __MODULE__
    )
  end

  def start_periodic_check do
    # Start a periodic timer that triggers the check_website function every N milliseconds
    # Trigger every hour
    Process.send_interval(self(), :check_website, 3_600_000)
  end

  def handle_info(:check_website, state) do
    # Perform the website-checking logic here
    new_state = process_check_website(state)

    # Schedule the next periodic check
    # Schedule the next check after an hour
    Process.send_after(self(), :check_website, 3_600_000)

    {:noreply, new_state}
  end

  def process_check_website(state) do
    # Logic to check the website
    # If something new is found, perform an action

    # Update the state with the current time
    current_time = :os.system_time(:millisecond)
    new_state = Map.put(state, :last_check_time, current_time)

    {:ok, new_state}
  end
end
