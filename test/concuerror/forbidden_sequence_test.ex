defmodule ForbiddenSequence.ConcurrencyTest do
  def push(pid, n) do
    Task.async(fn -> 
      GenServer.cast(pid, {:push, n})
    end)
  end

  @doc """
  The ForbiddenSequence module is a GenServer that receives numbers
  via the {:push, n} cast handler, and add them sequentially in a list.
  If it receives the sequence [4, 2, 3, 5, 1], it crashes.
  
  This (very artificial) test spawns 5 tasks in parallel, each of them
  pushes a number from 1 to 5 to the GenServer. That makes 5! = 120
  possible arrival orders for the numbers, with only 1 of them making
  the test fail.
  """
  def test do
    {:ok, pid} = GenServer.start_link(ForbiddenSequence, [])

    # If you generate numbers from 1 to 4 only, the test should pass
    1..5 |> Enum.each(fn i -> push(pid, i) end)

    # This is necessary. Even if there was no crash of the GenServer,
    # not stopping it would make Concuerror believe that the process
    # is stuck forever, as no new process can ever send it messages in
    # this test.
    GenServer.stop(pid)
  end
end
