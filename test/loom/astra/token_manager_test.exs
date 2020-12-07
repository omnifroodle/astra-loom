defmodule Loom.Astra.TokenManagerTest do
  use ExUnit.Case, async: true

  setup do
    start_supervised!(Loom.Astra.TokenManager)
    %{}
  end

  test "get token" do
    {:ok, _} = Loom.Astra.TokenManager.get_token()
  end
end
