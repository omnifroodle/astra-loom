defmodule LoomWeb.PageController do
  use LoomWeb, :controller
  alias Loom.Assent.MultiProvider, as: Auth

  def index(conn, _params) do
    {:ok, %{url: oauth_google_url, session_params: session_params}} = Auth.request(:google, LoomWeb.Endpoint.url())
    conn = put_session(conn, :assent, session_params)

    render(conn, "index.html",[oauth_google_url: oauth_google_url])
  end
end
