defmodule LobbygameWeb.PageController do
  use LobbygameWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
