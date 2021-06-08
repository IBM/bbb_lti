defmodule BbbLtiWeb.HealthControllerTest do
  use BbbLtiWeb.ConnCase

  describe "#index:" do
    test "ensure 200 is produced by health check", %{conn: conn} do
      conn = get(conn, Routes.health_path(conn, :index))
      assert response(conn, 200)
    end
  end
end
