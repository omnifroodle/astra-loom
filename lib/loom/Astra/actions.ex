defmodule Loom.Astra.Actions do
  @config Application.get_env(:loom, Loom.Astra)
  @url "https://#{@config[:id]}-#{@config[:region]}.apps.astra.datastax.com/api/rest"


  def get_token do
    case HTTPoison.post "#{@url}/v1/auth",
      "{\"username\": \"#{@config[:username]}\", \"password\": \"#{@config[:password]}\"}",
      [{"Content-Type", "application/json"},
      {"accept", "*/*"},
      {"x-cassandra-request-id", UUID.uuid1()}] do
    {:ok, %HTTPoison.Response{body: body}} ->
      {:ok, Jason.decode!(body)["authToken"]}
    other ->
      IO.inspect other
      {:error, "something went wrong!"}
    end
  end

  # TODO  Enum.map(a, fn {k,v} -> %{name: k, value: v} end)
  def upsert(token, table, entity) do
    {:ok, body} = Jason.encode(%{columns: entity})
    case HTTPoison.post "#{@url}/v1/keyspaces/#{@config[:keyspace]}/tables/#{table}/rows",
      body,
        [{"Content-Type", "application/json"},
        {"accept", "application/json"},
        {"x-cassandra-token", token},
        {"x-cassandra-request-id", UUID.uuid1()}] do
      {:ok, %HTTPoison.Response{status_code: 201, body: body}} ->
        {:ok, Jason.decode!(body)}
      {_, message} ->
        IO.inspect message
        {:error, "something went wrong!"}
    end
  end


  def select(token, table, primary_key) do
    case HTTPoison.get "#{@url}/v1/keyspaces/#{@config[:keyspace]}/tables/#{table}/rows/#{primary_key}",
      [{"Content-Type", "application/json"},
      {"accept", "application/json"},
      {"x-cassandra-token", token},
      {"x-cassandra-request-id", UUID.uuid1()}] do
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
      {:ok, Jason.decode!(body, keys: :atoms)}
    {:ok, %HTTPoison.Response{status_code: 404, body: _}} ->
      {:ok, %{rows: []}}
    other ->
      IO.inspect other
      {:error, "something went wrong!"}
    end
  end

end
