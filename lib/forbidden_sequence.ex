defmodule ForbiddenSequence do
  use GenServer

  def init(_), do: {:ok, []}

  def handle_cast({:push, n}, sequence) do
    new_sequence = [n | sequence]

    if new_sequence == [1, 5, 3, 2, 4] do
      raise "Error: received forbidden sequence"
    end

    {:noreply, new_sequence}
  end
end
