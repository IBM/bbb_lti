defmodule BbbLtiWeb.MeetingController do
  use BbbLtiWeb, :controller

  alias BbbLti.Meetings
  alias BbbLti.Meetings.Meeting
  alias BbbLti.BbbApi

  import BbbLtiWeb.Helpers.AccessControlHelper

  @dev_session %{
    id: "1",
    name: "John Smith",
    unit_id: "some unit_id",
    role: "Instructor"
  }

  plug :require_current_user
  plug :require_role_instructor when action in [:new, :create, :edit, :update, :delete]

  def index(conn, _params) do
    user = get_session(conn, :current_user)
    meetings = Meetings.list_meetings(user.unit_id)

    recordings =
      if length(meetings) > 0 do
        Enum.map(meetings, & &1.meeting_id)
        |> BbbApi.get_recordings()
      else
        []
      end

    render(conn, "index.html", meetings: meetings, user: user, recordings: recordings)
  end

  def new(conn, _params) do
    url = get_session(conn, :default_presentation)
    changeset = Meetings.change_meeting(%Meeting{}, %{"presentation_url" => url})

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"meeting" => form_params}) do
    meeting_params =
      get_session(conn, :current_user)
      |> apply_meeting_meta(form_params)

    case Meetings.create_meeting(meeting_params) do
      {:ok, _} ->
        conn
        |> put_flash(:success, "Session created successfully.")
        |> redirect(to: Routes.meeting_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    meeting = Meetings.get_meeting!(id)
    user_info = get_session(conn, :current_user)

    options = %{
      name: meeting.meeting_name,
      record: true,
      presentation_url: meeting.presentation_url,
      autoStartRecording: meeting.auto_start_recording,
      webcamsOnlyForModerator: meeting.webcams_only_for_moderator,
      muteOnStart: meeting.mute_on_start
    }

    case BbbApi.join_url(meeting.meeting_id, user_info, options) do
      {:ok, url} ->
        redirect(conn, external: url)

      {:error, reason} ->
        conn
        |> put_flash(:error, "Could not join the meeting: #{reason}")
        |> redirect(to: Routes.meeting_path(conn, :index))
    end
  end

  def edit(conn, %{"id" => id}) do
    meeting = Meetings.get_meeting!(id) |> convert_datetime()
    changeset = Meetings.change_meeting(meeting)
    render(conn, "edit.html", meeting: meeting, changeset: changeset)
  end

  def update(conn, %{"id" => id, "meeting" => meeting_params}) do
    meeting = Meetings.get_meeting!(id)
    meeting_params = convert_datetime(meeting_params)

    case Meetings.update_meeting(meeting, meeting_params) do
      {:ok, _} ->
        conn
        |> put_flash(:success, "Session updated successfully.")
        |> redirect(to: Routes.meeting_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", meeting: meeting, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    meeting = Meetings.get_meeting!(id)
    {:ok, _meeting} = Meetings.delete_meeting(meeting)

    conn
    |> put_flash(:info, "Session deleted successfully.")
    |> redirect(to: Routes.meeting_path(conn, :index))
  end

  defp require_current_user(conn, _) do
    conn = maybe_set_dev_session(conn)

    case get_session(conn, :current_user) do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> put_view(BbbLtiWeb.ErrorView)
        |> render("401.html")
        |> halt()

      _ ->
        conn
    end
  end

  defp require_role_instructor(conn, _) do
    if get_session(conn, :current_user) |> is_instructor?() do
      conn
    else
      conn
      |> put_flash(:info, "Only instructors can access this page")
      |> redirect(to: Routes.meeting_path(conn, :index))
      |> halt()
    end
  end

  defp apply_meeting_meta(current_user, form_params) do
    Map.merge(
      %{
        "created_by" => current_user.id,
        "meeting_id" => Ecto.UUID.generate(),
        "unit_id" => current_user.unit_id
      },
      convert_datetime(form_params)
    )
  end

  defp convert_datetime(%{"when" => dt, "time_zone" => tz} = form_params) when is_bitstring(tz) do
    local_time = dt 
    |> Timex.parse!("{ISO:Extended}") 
    |> Timex.to_datetime(Map.fetch!(form_params, "time_zone_local"))
    selected_time = dt 
    |> Timex.parse!("{ISO:Extended}") 
    |> Timex.to_datetime(tz)
    local_time_offset = local_time.std_offset 
    |> Timex.Timezone.total_offset(local_time.utc_offset)
    selected_time_offset = selected_time.std_offset 
    |> Timex.Timezone.total_offset(selected_time.utc_offset)
    time_difference = (local_time_offset - selected_time_offset) / 3600
    put_in(
      form_params,
      ["when"],
      dt
      |> Timex.parse!("{ISO:Extended}") 
      |> Timex.shift(hours: trunc(time_difference))
    )
  end

  defp convert_datetime(%Meeting{when: dt, time_zone: tz} = form_params) do
    Map.update!(form_params, :when, fn _ -> Timex.to_datetime(dt, tz) end)
  end

  defp convert_datetime(m), do: m

  defp maybe_set_dev_session(conn) do
    case {get_session(conn, :current_user), Application.get_env(:bbb_lti, :environment)} do
      {nil, :dev} -> put_session(conn, :current_user, @dev_session)
      _ -> conn
    end
  end
end
