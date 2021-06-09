defmodule Jabbax.Document.ErrorSourceTest do
  use ExUnit.Case
  alias Jabbax.Document.ErrorSource

  describe "from_attribute/2" do
    test "simple pointer" do
      assert ErrorSource.from_attribute(:first_name) ==
               %ErrorSource{pointer: "/data/attributes/first_name"}
    end

    test "pointer with one-level prefix" do
      assert ErrorSource.from_attribute(:city, ["address"]) ==
               %ErrorSource{pointer: "/data/attributes/address/city"}
    end

    test "pointer with multi-level prefix" do
      assert ErrorSource.from_attribute(:type, ["decision", "rationale", "reasoning"]) ==
               %ErrorSource{pointer: "/data/attributes/decision/rationale/reasoning/type"}
    end
  end
end
