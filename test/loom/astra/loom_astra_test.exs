defmodule Loom.Astra.ActionsTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, token} = Loom.Astra.Actions.get_token
    %{token: token}
  end

  test "get token" do
    {:ok, _} = Loom.Astra.Actions.get_token
  end

  test "push data", %{token: token} do
    Loom.Astra.Actions.upsert(token, "test", %{columns: [%{name: "key", value: "value"}]})
  end

  test "get data", %{token: token} do
    Loom.Astra.Actions.select(token, "test", "value")
  end
end
