defmodule CodeownersTest do
  @moduledoc """
  Test suite for `Codeowners`.
  """

  use ExUnit.Case
  doctest Codeowners

  describe "load" do
    test "gives a %Codeowners{}" do
      path = Path.expand("./test/CODEOWNERS")
      assert %Codeowners{} = Codeowners.load(path)
    end
  end

  describe "build" do
    test "gives a %Codeowners{}" do
      assert %Codeowners{} = Codeowners.build()
    end
  end
end
