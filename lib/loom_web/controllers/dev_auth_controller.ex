defmodule LoomWeb.DevAuthController do
  use LoomWeb, :controller

  @doc """
  `index/2` handles creation and login of randomly generated user
  """
  def index(conn, params) do
    if Application.get_env(:loom, :dev_login) == true do
      {:ok, profile} = Loom.RandomUser.get()
        |> Loom.User.get_or_create
      conn
        |> Loom.Guardian.Plug.sign_in(profile)
        |> redirect(to: "/chat")
    else
      redirect(conn, to: "/")
    end

  end
end
