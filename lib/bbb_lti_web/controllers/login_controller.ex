defmodule BbbLtiWeb.LoginController do
  use BbbLtiWeb, :controller

  plug :redirect_if_admin when action in [:index, :create]

  def index(conn, _), do: render(conn, "index.html")

  def create(conn, %{"access_key" => access_key, "secret_key" => secret_key}) do
    case valid_credentials?(access_key, secret_key) do
      true ->
        conn |> put_session(:admin, true) |> redirect(to: "/admin")

      false ->
        conn
        |> put_status(:bad_request)
        |> put_flash(:error, "Invalid credentials.")
        |> render("index.html")
    end
  end

  def delete(conn, _),
    do: conn |> delete_session(:admin) |> redirect(to: Routes.login_path(conn, :index))

  defp valid_credentials?(access_key, secret_key) do
    SecureCompare.compare(access_key, System.get_env("API_ACCESS_KEY", "")) and
      SecureCompare.compare(secret_key, System.get_env("API_SECRET_KEY", ""))
  end

  defp redirect_if_admin(conn, _) do
    case get_session(conn, :admin) do
      true -> redirect(conn, to: "/admin") |> halt()
      _ -> conn
    end
  end
end
