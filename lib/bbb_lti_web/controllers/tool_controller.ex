defmodule BbbLtiWeb.ToolController do
  use BbbLtiWeb, :controller

  action_fallback BbbLtiWeb.FallbackController

  alias BbbLti.{Clients, Validator}

  def validate_lti(conn, params) do
    validation_string = create_validation_string(params)
    client_id = URI.decode_www_form(params["oauth_consumer_key"])

    with {:ok, client_secret} <- Clients.get_client_secret(client_id),
         {:ok, _} <- check_required_session_params(params),
         {:ok, _} <-
           Validator.validate_signature(
             "#{Application.get_env(:bbb_lti, :host)}/tool",
             validation_string,
             client_secret
           ) do
      conn
      |> put_session(:current_user, %{
        id: params["user_id"],
        name: params["lis_person_sourcedid"],
        unit_id: params["resource_link_id"],
        role: params["roles"]
      })
      |> put_session(:default_presentation, params["custom_presentation_url"])
      |> redirect(to: Routes.meeting_path(conn, :index))
    end
  end

  defp create_validation_string(params) do
    Enum.map(params, fn {key, value} ->
      if String.starts_with?(key, "oauth_") and value |> is_encoded?() do
        {key, value}
      else
        {key, URI.encode(value, &URI.char_unreserved?/1)}
      end
    end)
    |> Enum.sort(fn {_, value2}, {_, value} -> value2 <= value end)
    |> Enum.reduce("OAuth ", fn {key, value}, acc ->
      acc <> "#{key}=\"#{value}\","
    end)
    |> String.trim_trailing(",")
  end

  defp is_encoded?(string) when is_binary(string),
    do: string != URI.decode(string)

  defp check_required_session_params(%{
         "lis_person_sourcedid" => _,
         "resource_link_id" => _,
         "roles" => _,
         "user_id" => _
       }),
       do: {:ok, nil}

  defp check_required_session_params(_),
    do: {:error, :missing_required_session_parameters}
end
