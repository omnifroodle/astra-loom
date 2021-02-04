defmodule Loom.RandomUser do
  require Poison
  
  def get() do
    response = HTTPoison.get!("https://randomuser.me/api/")
    IO.inspect response.body
    {:ok, result} = Poison.decode(response.body, %{keys: :atoms})
    [faker | _] = result.results
    uuid = UUID.uuid1()
    %{
      "name" => "#{faker.name.first} #{faker.name.last}",
      "picture" => faker.picture.thumbnail,
      "uuid" => uuid,
      "sub" => "dev->#{uuid}"
    }
  end
end