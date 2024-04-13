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

  describe "owners_for_path" do
    test "gives a list" do
      codeowners = Codeowners.build()
      assert [] = Codeowners.owners_for_path(codeowners, "./test")
    end

    test "matches *" do
      codeowners = Codeowners.build("* @team")
      assert ["@team"] = Codeowners.owners_for_path(codeowners, "/test")
    end

    test "matches * with extension" do
      codeowners = Codeowners.build("*.js @team")
      assert ["@team"] = Codeowners.owners_for_path(codeowners, "/test.js")
    end

    test "matches directory starting at root" do
      codeowners = Codeowners.build("/build/logs/ @team")
      assert ["@team"] = Codeowners.owners_for_path(codeowners, "/build/logs/test.log")
    end

    test "matches rootless directory" do
      codeowners = Codeowners.build("docs/ @team")
      assert ["@team"] = Codeowners.owners_for_path(codeowners, "/app/docs/setup/info.md")
    end

    test "matches directory" do
      codeowners = Codeowners.build("docs/* @team")
      assert ["@team"] = Codeowners.owners_for_path(codeowners, "docs/getting-started.md")
      assert [] = Codeowners.owners_for_path(codeowners, "docs/build-app/troubleshooting.md")
    end
  end

  describe "owners_for_module" do
    test "gives a list" do
      codeowners = Codeowners.build()
      module = Codeowners
      assert [] = Codeowners.owners_for_module(codeowners, module)
    end
  end
end
