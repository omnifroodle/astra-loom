defmodule Loom.Astra.Actions.Namespace do
  @config Application.get_env(:loom, Loom.Astra)

  use HTTPoison.Base

  @url "https://#{@config[:id]}-#{@config[:region]}.apps.astra.datastax.com/api/rest/v2/namespaces/#{@config[:keyspace]}/collections/"

  def process_request_url(url) do
    IO.inspect url
    @url <> url
  end

  def process_request_headers(headers) do
    {:ok, token} = Loom.Astra.TokenManager.get_token
    headers ++ [{"Content-Type", "application/json"},
                {"accept", "application/json"},
                {"x-cassandra-token", token},
                {"x-cassandra-request-id", UUID.uuid1()}]
  end

  def process_request_options(options) do
    options ++ [ssl: [{:versions, [:'tlsv1.2']}]]
  end

  def fetch(collection, id) do
    IO.inspect @url
    {status, %{data: data }} = get("#{URI.encode(collection)}/#{URI.encode(id)}")
      |> parse_response
    {status, data}
  end

  def create(collection, %{"sub" => id} = doc) do
    {:ok, body} = Jason.encode(doc)
    put("#{collection}/#{id}", body)
      |> parse_response
  end

  defp parse_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}), do: {:ok, Jason.decode!(body, keys: :atoms)}
  defp parse_response({:ok, %HTTPoison.Response{status_code: 204}}), do: {:miss, %{data: {}}}
  defp parse_response({:ok, %HTTPoison.Response{status_code: 409}}), do: {:rejected, "duplicate"}
  defp parse_response(resp), do: {:error, resp}

end
