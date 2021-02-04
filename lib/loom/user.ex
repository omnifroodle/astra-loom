defmodule Loom.User do

  def get(id) do
    Astra.Document.get_doc("loom", "users", id)
  end

  def create(user) do
    {:ok, user} = Astra.Document.put_doc("loom", "users", user["sub"], user)
  end

  def get_or_create(user) do
    case get(user["sub"]) do
      {:ok, []} ->
        user_with_default_threads = Map.put(user, "threads", %{
                "main" => %{"enabled" => true}, 
                "lobby" => %{"enabled" => true}
                })
                
                
                IO.puts("user with def threads")
                IO.inspect user_with_default_threads
        {:ok, _} = create(user_with_default_threads)
        {:ok, user_with_default_threads}
      {:ok, ret} ->
        IO.puts "Ret"
        IO.inspect ret
        {:ok, ret}

    end
  end
end
