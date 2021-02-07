defmodule Loom.User do

  def get(id) do
    Astra.Document.get_doc("loom", "users", id)
  end

  def create(user) do
    {:ok, _} = Astra.Document.put_doc("loom", "users", user["sub"], user)
  end

  def get_or_create(user) do
    case get(user["sub"]) do
      {:ok, []} ->
        user_with_default_threads = Map.put(user, "threads", %{
                "main" => %{"enabled" => true},
                "lobby" => %{"enabled" => true}
                })
        {:ok, _} = create(user_with_default_threads)
        {:ok, user_with_default_threads}
      {:ok, ret} ->
        {:ok, ret}
    end
  end
  
  def update_thread(id, thread, enabled) do
    {:ok, _} = Astra.Document.put_sub_doc("loom", "users", id, "threads/#{thread}", %{"enabled" => enabled})
  end
end
