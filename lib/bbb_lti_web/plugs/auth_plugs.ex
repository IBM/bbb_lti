defmodule BbbLtiWeb.Plugs.AuthPlugs do
  use BbbLtiWeb, :controller

  def fix_xframe_options(conn, _), do: delete_resp_header(conn, "x-frame-options")

  def require_admin_credentials(conn, _) do
    case get_session(conn, :admin) do
      true ->
        conn

      _ ->
        conn
        |> redirect(to: Routes.login_path(conn, :index))
        |> halt()
    end
  end
end
