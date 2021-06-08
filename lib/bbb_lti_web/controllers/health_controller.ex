defmodule BbbLtiWeb.HealthController do
  use BbbLtiWeb, :controller

  def index(conn, _) do
    send_resp(conn, 200, "LTI Provider is running: OK")
  end
end
