defmodule IronicTest do
  use ExUnit.Case
  doctest Ironic

  test "greets the world" do
    assert Ironic.hello() == :world
  end
end
