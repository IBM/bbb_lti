defmodule BbbLti.MeetingsTest do
  use BbbLti.DataCase

  alias BbbLti.Meetings

  describe "meetings" do
    alias BbbLti.Meetings.Meeting

    @valid_attrs %{
      meeting_id: "some meeting_id",
      created_by: "foo",
      meeting_name: "some name",
      unit_id: "some unit_id",
      when: "2010-04-17T14:00:00Z",
      time_zone: "America/Toronto",
      duration: 30
    }
    @update_attrs %{
      meeting_id: "some updated meeting_id",
      created_by: "foo",
      meeting_name: "some updated name",
      unit_id: "some updated unit_id",
      when: "2011-05-18T15:01:01Z",
      time_zone: "America/Toronto",
      duration: 30
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

    def meeting_fixture(attrs \\ %{}) do
      {:ok, meeting} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Meetings.create_meeting()

      meeting
    end

    test "list_meetings/1 returns all meetings" do
      meeting = meeting_fixture()
      assert Meetings.list_meetings(@valid_attrs.unit_id) == [meeting]
    end

    test "get_meeting!/1 returns the meeting with given id" do
      meeting = meeting_fixture()
      assert Meetings.get_meeting!(meeting.id) == meeting
    end

    test "create_meeting/1 with valid data creates a meeting" do
      assert {:ok, %Meeting{} = meeting} = Meetings.create_meeting(@valid_attrs)
      assert meeting.meeting_id == "some meeting_id"
      assert meeting.meeting_name == "some name"
      assert meeting.unit_id == "some unit_id"
      assert meeting.when == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
    end

    test "create_meeting/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Meetings.create_meeting(@invalid_attrs)
    end

    test "update_meeting/2 with valid data updates the meeting" do
      meeting = meeting_fixture()
      assert {:ok, %Meeting{} = meeting} = Meetings.update_meeting(meeting, @update_attrs)
      assert meeting.meeting_id == "some updated meeting_id"
      assert meeting.meeting_name == "some updated name"
      assert meeting.unit_id == "some updated unit_id"
      assert meeting.when == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
    end

    test "update_meeting/2 with invalid data returns error changeset" do
      meeting = meeting_fixture()
      assert {:error, %Ecto.Changeset{}} = Meetings.update_meeting(meeting, @invalid_attrs)
      assert meeting == Meetings.get_meeting!(meeting.id)
    end

    test "delete_meeting/1 deletes the meeting" do
      meeting = meeting_fixture()
      assert {:ok, %Meeting{}} = Meetings.delete_meeting(meeting)
      assert_raise Ecto.NoResultsError, fn -> Meetings.get_meeting!(meeting.id) end
    end

    test "change_meeting/1 returns a meeting changeset" do
      meeting = meeting_fixture()
      assert %Ecto.Changeset{} = Meetings.change_meeting(meeting)
    end
  end
end
