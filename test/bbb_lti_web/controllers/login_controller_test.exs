defmodule BbbLtiWeb.LoginControllerTest do
  use BbbLtiWeb.ConnCase

  @test_access_key "access"
  @test_secret_key "secret"

  describe "#index" do
    test "renders the login form", %{conn: conn} do
      conn = get(conn, Routes.login_path(conn, :index))
      assert html_response(conn, 200) =~ Routes.login_path(conn, :create)
    end

    @tag :admin_session
    test "redirects when already logged in", %{conn: conn} do
      conn = get(conn, Routes.login_path(conn, :index))
      assert redirected_to(conn) == "/admin"
    end
  end

  describe "#create" do
    setup do
      old_access_key = System.get_env("API_ACCESS_KEY", "")
      old_secret_key = System.get_env("API_SECRET_KEY", "")

      on_exit(fn ->
        System.put_env("API_ACCESS_KEY", old_access_key)
        System.put_env("API_SECRET_KEY", old_secret_key)
      end)

      System.put_env("API_ACCESS_KEY", @test_access_key)
      System.put_env("API_SECRET_KEY", @test_secret_key)
    end

    test "logs in with valid credentials", %{conn: conn} do
      conn =
        post(conn, Routes.login_path(conn, :create), %{
          "access_key" => @test_access_key,
          "secret_key" => @test_secret_key
        })

      assert get_session(conn, :admin)
      assert redirected_to(conn) == "/admin"
    end

    test "shows error on invalid credentials", %{conn: conn} do
      conn =
        post(conn, Routes.login_path(conn, :create), %{
          "access_key" => "invalidaccesskey",
          "secret_key" => "invalidsecret"
        })

      assert html_response(conn, :bad_request) =~ "Invalid credentials."
      assert html_response(conn, :bad_request) =~ "invalidaccesskey"
      refute html_response(conn, :bad_request) =~ "invalidsecret"
    end

    @tag :admin_session
    test "redirects when already logged in", %{conn: conn} do
      conn = get(conn, Routes.login_path(conn, :index), %{"access_key" => "", "secret_key" => ""})
      assert redirected_to(conn) == "/admin"
    end
  end

  describe "#delete" do
    @tag :admin_session
    test "logs out and redirects to login page", %{conn: conn} do
      assert get_session(conn, :admin)
      conn = delete(conn, Routes.login_path(conn, :delete))
      refute get_session(conn, :admin)
      assert redirected_to(conn) =~ Routes.login_path(conn, :index)
    end

    test "redirects to login page when not logged in", %{conn: conn} do
      conn = delete(conn, Routes.login_path(conn, :delete))
      assert redirected_to(conn) =~ Routes.login_path(conn, :index)
    end
  end
end
