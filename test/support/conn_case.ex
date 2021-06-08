defmodule BbbLtiWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use BbbLtiWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import BbbLtiWeb.ConnCase

      alias BbbLtiWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint BbbLtiWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(BbbLti.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(BbbLti.Repo, {:shared, self()})
    end

    conn = Phoenix.ConnTest.build_conn()

    conn =
      case tags[:authenticate_api] do
        true ->
          conn
          |> Plug.Conn.put_req_header(
            "authorization",
            "Basic " <>
              Base.encode64(
                "#{Application.get_env(:bbb_lti, :auth_config)[:username]}:#{
                  Application.get_env(:bbb_lti, :auth_config)[:password]
                }"
              )
          )

        nil ->
          conn

        attrs ->
          conn
          |> Plug.Conn.put_req_header(
            "authorization",
            "Basic " <> Base.encode64("#{attrs.username}:#{attrs.password}")
          )
      end

    conn =
      case tags[:user_session] do
        true ->
          conn
          |> Plug.Test.init_test_session(%{
            current_user: %{id: "foo", unit_id: "bar", role: "Instructor", name: "admin"}
          })

        nil ->
          conn

        attrs ->
          conn
          |> Plug.Test.init_test_session(%{current_user: attrs})
      end

    conn =
      case tags[:admin_session] do
        true -> conn |> Plug.Test.init_test_session(admin: true)
        nil -> conn
      end

    {:ok, conn: conn}
  end
end
