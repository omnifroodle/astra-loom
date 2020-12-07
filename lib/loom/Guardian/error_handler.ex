defmodule Loom.Guardian.ErrorHandler do
  import Plug.Conn
  use LoomWeb, :controller
  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {_type, _reason}, _opts) do
    conn
    |> redirect(to: "/")
  end
end
