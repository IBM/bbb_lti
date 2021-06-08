defmodule BbbLtiWeb.Admin.AdminTest do
  use BbbLtiWeb.ConnCase

  test "redirects user when not admin", %{conn: conn} do
    conn = get(conn, "/admin")
    assert redirected_to(conn), Routes.login_path(conn, :index)
  end

  @tag :admin_session
  test "renders the dashboard when signed in as admin", %{conn: conn} do
    conn = get(conn, "/admin")
    assert redirected_to(conn), "/admin/dashboard"
  end

  @tag :admin_session
  test "renders log out button(s)", %{conn: conn} do
    conn = get(conn, "/admin")
    conn = conn |> recycle() |> get("/admin/dashboard")
    assert html_response(conn, 200) =~ "Log Out"
  end
end
