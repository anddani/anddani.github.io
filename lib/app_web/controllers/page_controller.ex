defmodule AppWeb.PageController do
  use AppWeb, :controller

  def home(conn, _params) do
    conn
    |> render(:home)
  end
end
