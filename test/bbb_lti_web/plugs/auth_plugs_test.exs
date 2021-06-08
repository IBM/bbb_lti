defmodule BbbLtiWeb.AuthPlugsTest do
  use BbbLtiWeb.ConnCase

  alias BbbLtiWeb.Plugs.AuthPlugs

  describe "require_admin_credentials/2" do
    test "redirects to login page if not logged in as admin", %{conn: conn} do
      updated_conn =
        conn
        |> Plug.Test.init_test_session(admin: nil)
        |> AuthPlugs.require_admin_credentials(nil)

      assert redirected_to(updated_conn) =~ Routes.login_path(updated_conn, :index)
    end

    @tag :admin_session
    test "no change if logged in as admin", %{conn: conn} do
      updated_conn = AuthPlugs.require_admin_credentials(conn, nil)
      assert conn == updated_conn
    end
  end
end
