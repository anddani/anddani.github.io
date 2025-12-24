defmodule AppWeb.SmtController do
  use AppWeb, :controller

  def index(conn, _params) do
    conn
    |> render(:index)
  end
end
