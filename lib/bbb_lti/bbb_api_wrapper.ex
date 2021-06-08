defmodule BbbLti.BbbApiWrapper do
  def bbb_endpoint, do: Application.get_env(:bbb_lti, :bbb_endpoint)
  def bbb_secret, do: Application.get_env(:bbb_lti, :bbb_secret)

  def send_api_request(params, method, req_body \\ "") do
    url = get_url(params, method)

    case HTTPoison.post(url, req_body, %{"Content-Type" => "application/xml"}) do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, body}

      # {:ok, %{status_code: 404}} ->
      #   # do something with a 404

      {:error, %{reason: reason}} ->
        {:error, reason}
    end
  end

  def join_meeting_url(meeting_id, password, user_name, options \\ %{}) do
    %{meetingID: meeting_id, password: password, fullName: user_name}
    |> Map.merge(options)
    |> get_url(:join)
  end

  def recordings(meeting_ids) when is_list(meeting_ids) do
    %{meetingID: Enum.join(meeting_ids, ",")}
    |> send_api_request(:getRecordings)
  end

  def recordings(meeting_ids) when is_bitstring(meeting_ids) do
    %{meetingID: meeting_ids}
    |> send_api_request(:getRecordings)
  end

  defp get_url(params, method) do
    params_string =
      Enum.to_list(params)
      |> Enum.map(fn {k, v} -> if is_boolean(v), do: {k, to_string(v)}, else: {k, v} end)
      |> Enum.sort(fn {k1, _}, {k2, _} -> k1 < k2 end)
      |> Enum.reduce("", fn {k, v}, acc -> acc <> "#{k}=#{URI.encode_www_form(v)}&" end)
      |> String.trim_trailing("&")

    checksum =
      :crypto.hash(:sha, "#{method}#{params_string}#{bbb_secret()}")
      |> Base.encode16()
      |> String.downcase()

    "#{bbb_endpoint()}/#{method}?#{params_string}&checksum=#{checksum}"
  end
end
