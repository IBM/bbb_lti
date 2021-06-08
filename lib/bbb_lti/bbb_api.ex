defmodule BbbLti.BbbApi do
  import BbbLti.BbbApiWrapper
  import SweetXml
  import BbbLtiWeb.Helpers.AccessControlHelper

  def create_meeting(meeting_id, unit_id, options) do
    # first separate presentation_url from options since we only want it in the request body
    {presentation_url, options} = Map.pop(options, :presentation_url)
    req_body = gen_presentation_url_body(presentation_url)

    Map.merge(%{meetingID: meeting_id}, gen_meeting_passwords(meeting_id, unit_id))
    |> Map.merge(options)
    |> send_api_request(:create, req_body)
  end

  def join_url(meeting_id, %{id: u_id, unit_id: unit_id, role: role, name: name}, options) do
    case create_meeting(meeting_id, unit_id, options) do
      {:ok, _} ->
        {:ok, generate_join_url(meeting_id, unit_id, role, name, u_id)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def join_url(_, _, _) do
    {:error, "User session is not valid"}
  end

  def get_recordings(meeting_ids) do
    case recordings(meeting_ids) do
      {:ok, xml_res} ->
        xml_res
        |> xpath(
          ~x"//recordings/recording"l,
          meeting_id: ~x"./meetingID/text()",
          record_id: ~x"./recordID/text()",
          state: ~x"./state/text()",
          participants: ~x"./participants/text()",
          url: ~x"./playback/format[last()]/url/text()"
        )

      {:error, _} ->
        []
    end
  end

  defp generate_join_url(meeting_id, unit_id, role, name, u_id) do
    password = gen_meeting_password(meeting_id, unit_id, role)
    join_meeting_url(meeting_id, password, name, %{joinViaHtml5: "true", userID: u_id})
  end

  def gen_meeting_passwords(meeting_id, unit_id) do
    %{
      attendeePW: gen_meeting_password(meeting_id, unit_id, "Student"),
      moderatorPW: gen_meeting_password(meeting_id, unit_id, "Instructor")
    }
  end

  defp gen_meeting_password(meeting_id, unit_id, role) do
    if is_instructor?(role) do
      :crypto.hash(:sha, "mp#{meeting_id}#{unit_id}") |> Base.encode16()
    else
      :crypto.hash(:sha, "ap#{meeting_id}#{unit_id}") |> Base.encode16()
    end
  end

  defp gen_presentation_url_body(nil), do: ""

  defp gen_presentation_url_body(url) do
    """
    <modules>
    <module name=\"presentation\">
      <document url=\"http://#{url}\"/>
    </module>
    </modules>
    """
  end
end
