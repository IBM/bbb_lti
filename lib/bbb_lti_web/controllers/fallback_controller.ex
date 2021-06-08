defmodule BbbLtiWeb.FallbackController do
  use BbbLtiWeb, :controller

  def call(conn, {:error, :secret_not_found = err}) do
    conn |> put_status(:forbidden) |> render("error.html", %{err: err})
  end

  def call(conn, {:error, err}) do
    conn |> put_status(:bad_request) |> render("error.html", %{err: err})
  end
end
