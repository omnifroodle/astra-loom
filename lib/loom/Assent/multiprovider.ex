defmodule Loom.Assent.MultiProvider do
  @spec request(atom(), String.t()) :: {:ok, map()} | {:error, term()}
  def request(provider, endpoint) do
    config =
      provider
      |> config!()
      |> add_host(endpoint)

    config[:strategy].authorize_url(config)
  end

  @spec callback(atom(), String.t(), map(), map()) :: {:ok, map()} | {:error, term()}
  def callback(provider, endpoint, params, session_params \\ %{}) do
    config =
      provider
      |> config!()
      |> add_host(endpoint)
      |> Assent.Config.put(:session_params, session_params)

    config[:strategy].callback(config, params)
  end

  defp add_host(config, endpoint) do
    Keyword.replace!(config, :redirect_uri,  endpoint <> config[:redirect_uri])
  end

  defp config!(provider) do
    Application.get_env(:loom, :strategies)[provider] || raise "No provider configuration for #{provider}"
  end
end
