defmodule BbbLtiWeb.Api.ClientsController do
  use BbbLtiWeb, :controller

  alias BbbLti.Clients
  alias BbbLti.Clients.Credential

  def get_or_create(conn, %{"clientId" => client_id, "clientSecret" => client_secret}) do
    case Clients.get_or_create(%{"client_id" => client_id, "client_secret" => client_secret}) do
      {:ok, %Credential{}} ->
        json(conn, %{error: false, message: "client with client id: #{client_id} created"})

      {:error, _} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: true, message: "failed to create lti client"})
    end
  end

  def get_or_create(conn, _),
    do:
      conn
      |> put_status(:bad_request)
      |> json(%{
        error: true,
        message: "Missing client_id and/or client_secret in request body"
      })
end
