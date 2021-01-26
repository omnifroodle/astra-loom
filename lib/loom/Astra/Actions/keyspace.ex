defmodule Loom.Astra.Actions.Keyspace do
  @config Application.get_env(:loom, Loom.Astra)
  use HTTPoison.Base

  @url "https://#{@config[:id]}-#{@config[:region]}.apps.astra.datastax.com/api/rest/v2/keyspaces/#{@config[:keyspace]}/"

  #TODO normalize this with astra headers in Namespace
  def process_request_url(url) do
    @url <> url
  end

  #TODO normalize this with astra headers in Namespace
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

  def select(table, primary_key) do
    {status, %{data: _ }} = get("#{table}/#{primary_key}")
      |> parse_response
  end

  def insert(table, entity) do
    {:ok, body} = Jason.encode(entity)
    post("#{table}", body)
      |> parse_response
  end

  defp parse_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}), do: {:ok, Jason.decode!(body, keys: :atoms)}
  defp parse_response({:ok, %HTTPoison.Response{status_code: 201, body: body}}), do: {:ok, Jason.decode!(body, keys: :atoms)}

  defp parse_response({:ok, %HTTPoison.Response{status_code: 204}}), do: {:miss, %{data: {}}}
  defp parse_response({:ok, %HTTPoison.Response{status_code: 409}}), do: {:rejected, "duplicate"}
  defp parse_response(resp), do: {:error, resp}

end
