defmodule CodeownersExTest do
  use ExUnit.Case
  doctest CodeownersEx

  test "greets the world" do
    assert CodeownersEx.hello() == :world
  end
end
