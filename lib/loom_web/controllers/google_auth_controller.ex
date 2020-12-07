defmodule LoomWeb.GoogleAuthController do
  use LoomWeb, :controller
  alias Loom.Assent.MultiProvider, as: Auth

  @doc """
  `index/2` handles the callback from Google Auth API redirect.
  """
  def index(conn, params) do
    {:ok, %{user: profile, token: _}} = Auth.callback(:google, LoomWeb.Endpoint.url(), params, get_session(conn, :assent))
    {:ok, profile} = Map.put(profile, 'uuid', UUID.uuid1())
      |> Map.update!("sub", &("goog->" <> &1))
      |> Loom.User.get_or_create
    conn
      |> Loom.Guardian.Plug.sign_in(profile)
      |> redirect(to: "/chat")
  end
end
