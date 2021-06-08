defmodule BbbLtiWeb.Api.ClientsControllerTest do
  use BbbLtiWeb.ConnCase

  alias BbbLti.Clients

  @client_params %{
    clientId: "@portal/some-id",
    clientSecret: "some-random-string"
  }

  describe "basic auth:" do
    test "fails when missing basic auth", %{conn: conn} do
      conn = post(conn, Routes.api_clients_path(conn, :get_or_create))
      assert response(conn, 401) =~ "Unauthorized"
    end

    @tag authenticate_api: %{username: "foo", password: "bar"}
    test "fails when basic auth invalid", %{conn: conn} do
      conn = post(conn, Routes.api_clients_path(conn, :get_or_create))
      assert response(conn, 401) =~ "Unauthorized"
    end

    @tag :authenticate_api
    test "basic auth succeeds but bad params", %{conn: conn} do
      conn = post(conn, Routes.api_clients_path(conn, :get_or_create))
      assert json_response(conn, 400)
    end

    @tag :authenticate_api
    test "basic request succeeds", %{conn: conn} do
      conn = post(conn, Routes.api_clients_path(conn, :get_or_create, @client_params))
      assert json_response(conn, 200)
    end
  end

  describe "#get_or_create:" do
    @tag :authenticate_api
    test "not found so create", %{conn: conn} do
      assert [] == Clients.list_credentials()
      conn = post(conn, Routes.api_clients_path(conn, :get_or_create, @client_params))
      [item] = Clients.list_credentials()
      assert item.client_id == @client_params.clientId
      assert json_response(conn, 200)
    end

    @tag :authenticate_api
    test "found credentials", %{conn: conn} do
      Clients.create_credential(%{
        "client_id" => @client_params.clientId,
        "client_secret" => @client_params.clientSecret
      })

      assert [item] = Clients.list_credentials()
      assert item.client_id == @client_params.clientId
      conn = post(conn, Routes.api_clients_path(conn, :get_or_create, @client_params))

      assert json_response(conn, 200) == %{
               "error" => false,
               "message" => "client with client id: #{@client_params.clientId} created"
             }
    end

    @tag :authenticate_api
    test "bad params", %{conn: conn} do
      conn =
        post(conn, Routes.api_clients_path(conn, :get_or_create, %{client_id: 12, secret: 32}))

      assert json_response(conn, 400)
    end
  end
end
