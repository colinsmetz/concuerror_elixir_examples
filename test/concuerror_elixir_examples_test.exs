defmodule ConcuerrorElixirExamplesTest do
  use ExUnit.Case
  doctest ConcuerrorElixirExamples

  test "greets the world" do
    assert ConcuerrorElixirExamples.hello() == :world
  end
end
