defmodule BbbLtiWeb.MeetingControllerTest do
  use BbbLtiWeb.ConnCase

  alias BbbLti.Meetings

  @ten_days_from_now Timex.now() |> Timex.shift(days: 10)
  @ten_days_before Timex.now() |> Timex.shift(days: -10)

  @create_attrs %{
    meeting_id: "some meeting_id",
    created_by: "foo",
    meeting_name: "some name",
    unit_id: "bar",
    when: Timex.now() |> Timex.Timezone.convert("America/Toronto") |> DateTime.to_iso8601(),
    time_zone: "EST",
    duration: 60
  }
  @update_attrs %{
    meeting_id: "some meeting_id",
    created_by: "foo",
    meeting_name: "some updated name",
    unit_id: "bar",
    when:
      @ten_days_from_now |> Timex.Timezone.convert("America/Toronto") |> DateTime.to_iso8601(),
    time_zone: "EST",
    duration: 60
  }
  @invalid_attrs %{
    meeting_id: nil,
    meeting_name: nil,
    unit_id: nil,
    when: nil,
    time_zone: nil,
    created_by: nil,
    duration: nil
  }

  def fixture(:meeting) do
    {:ok, meeting} = Meetings.create_meeting(@create_attrs)
    meeting
  end

  describe "index" do
    setup [:create_meeting]

    @tag :user_session
    test "lists all meetings", %{conn: conn} do
      conn = get(conn, Routes.meeting_path(conn, :index))
      assert html_response(conn, 200) =~ "Schedule a Session"
    end

    @tag user_session: %{id: "foo", unit_id: "bar", role: "Student"}
    test "only instructors see new, edit and delete actions in the view", %{conn: conn} do
      conn = get(conn, Routes.meeting_path(conn, :index))
      refute html_response(conn, 200) =~ "Schedule a Session"
      assert html_response(conn, 200) =~ "Upcoming Sessions"
    end

    @tag user_session: %{id: "foo", unit_id: "bar", role: "Administrator"}
    test "alternate role title: admins see new, edit and delete actions in the view", %{
      conn: conn
    } do
      conn = get(conn, Routes.meeting_path(conn, :index))
      assert html_response(conn, 200) =~ "Schedule a Session"
    end

    test "fails without session", %{conn: conn} do
      conn = get(conn, Routes.meeting_path(conn, :index))
      assert html_response(conn, 401)
    end

    @tag :user_session
    test "Past Sessions table is not visible when there are no past meetings", %{
      conn: conn
    } do
      conn = get(conn, Routes.meeting_path(conn, :index))
      refute html_response(conn, 200) =~ "Past Sessions"

      @create_attrs
      |> Map.put(:when, @ten_days_before)
      |> Meetings.create_meeting()

      conn = get(conn, Routes.meeting_path(conn, :index))
      assert html_response(conn, 200) =~ "Past Sessions"
    end
  end

  describe "new meeting" do
    @tag :user_session
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.meeting_path(conn, :new))
      assert html_response(conn, 200)
    end
  end

  describe "create meeting" do
    @tag :user_session
    test "redirects to index after saving", %{conn: conn} do
      conn = post(conn, Routes.meeting_path(conn, :create), meeting: @create_attrs)
      assert redirected_to(conn) == Routes.meeting_path(conn, :index)
      conn = get(recycle(conn), Routes.meeting_path(conn, :index))

      assert html_response(conn, 200) =~
               @create_attrs.when
               |> Timex.parse!("{ISO:Extended}")
               |> Timex.format!("%-I:%M %P", :strftime)
    end

    @tag :user_session
    test "inputted time is persisted as UTC time", %{conn: conn} do
      post(conn, Routes.meeting_path(conn, :create), meeting: @create_attrs)
      meeting = Meetings.get_meeting(@create_attrs.meeting_id)
      assert meeting.when.day == Timex.now().day
      assert meeting.when.hour == Timex.now().hour
    end

    @tag :user_session
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.meeting_path(conn, :create), meeting: @invalid_attrs)
      assert html_response(conn, 200)
    end

    @tag user_session: %{id: "foo", unit_id: "bar", role: "Student"}
    test "fails without instructor session", %{conn: conn} do
      conn = post(conn, Routes.meeting_path(conn, :create), meeting: @invalid_attrs)
      assert html_response(conn, 302)
    end
  end

  describe "edit meeting" do
    @tag :user_session
    setup [:create_meeting]

    test "renders form for editing chosen meeting", %{conn: conn, meeting: meeting} do
      conn = get(conn, Routes.meeting_path(conn, :edit, meeting))
      assert html_response(conn, 200) =~ "Edit Session"
    end

    @tag user_session: %{id: "foo", unit_id: "bar", role: "Administrator"}
    test "alternate role title: admins can navigate to edit", %{conn: conn, meeting: meeting} do
      conn = get(conn, Routes.meeting_path(conn, :edit, meeting))
      assert html_response(conn, 200) =~ "Edit Session"
    end
  end

  describe "update meeting" do
    setup [:create_meeting]

    @tag :user_session
    test "redirects when data is valid", %{conn: conn, meeting: meeting} do
      conn = put(conn, Routes.meeting_path(conn, :update, meeting), meeting: @update_attrs)

      conn = get(conn, Routes.meeting_path(conn, :index))
      assert html_response(conn, 200) =~ "some updated name"
    end

    @tag :user_session
    test "renders errors when data is invalid", %{conn: conn, meeting: meeting} do
      conn = put(conn, Routes.meeting_path(conn, :update, meeting), meeting: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Session"
    end

    @tag :user_session
    test "time is persisted in UTC", %{conn: conn, meeting: meeting} do
      put(conn, Routes.meeting_path(conn, :update, meeting), meeting: @update_attrs)
      meeting = Meetings.get_meeting(@update_attrs.meeting_id)
      assert meeting.when.day == @ten_days_from_now.day
      assert meeting.when.hour == @ten_days_from_now.hour
    end
  end

  describe "delete meeting" do
    @tag :user_session
    setup [:create_meeting]

    test "deletes chosen meeting", %{conn: conn, meeting: meeting} do
      conn = delete(conn, Routes.meeting_path(conn, :delete, meeting))
      assert redirected_to(conn) == Routes.meeting_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.meeting_path(conn, :show, meeting))
      end
    end

    @tag user_session: %{id: "foo", unit_id: "bar", role: "Staff"}
    test "alternate role title: staff can delete", %{conn: conn, meeting: meeting} do
      conn = delete(conn, Routes.meeting_path(conn, :delete, meeting))
      assert redirected_to(conn) == Routes.meeting_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.meeting_path(conn, :show, meeting))
      end
    end

    @tag user_session: %{id: "foo", unit_id: "bar", role: "Student"}
    test "fails without instructor session", %{conn: conn, meeting: meeting} do
      conn = delete(conn, Routes.meeting_path(conn, :delete, meeting))
      assert html_response(conn, 302)
    end
  end

  defp create_meeting(_) do
    meeting = fixture(:meeting)
    %{meeting: meeting}
  end
end
