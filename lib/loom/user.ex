defmodule Loom.User do

  def get(id) do
    Loom.Astra.Actions.Namespace.fetch("users", id)
  end

  # TODO test user object is sig
  def create(user) do
    {:ok, _} = Loom.Astra.Actions.Namespace.create("users", user)
  end

  def get_or_create(user) do
    case get(user["sub"]) do
      {:ok, ret} ->
        {:ok, ret}
      {:miss, _} ->
        user_with_default_threads = Map.put(user, "threads", %{"main" => %{"enabled" => true}, "lobby" => %{"enabled" => true}})
        {:ok, _} = create(user_with_default_threads)
        {:ok, user_with_default_threads}
    end
  end
end
