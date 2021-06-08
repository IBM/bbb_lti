defmodule BbbLtiWeb.Helpers.MeetingHelper do
  use Timex
  alias BbbLti.BbbApi

  def upcoming_meetings(meetings) do
    meetings
    |> Enum.filter(&(!meeting_ended?(&1)))
    |> Enum.sort(&(Timex.compare(&1.when, &2.when) < 1))
  end

  def past_meetings(meetings) do
    meetings
    |> Enum.filter(&meeting_ended?(&1))
    |> Enum.sort(&(Timex.compare(&1.when, &2.when) == 1))
  end

  def relative_time(%{:when => utc_datetime}) do
    Timex.from_now(utc_datetime)
  end

  def readable_date(%{:when => utc_datetime, :time_zone => time_zone}) do
    relative_date =
      Timex.to_datetime(utc_datetime, time_zone)
      |> Timex.to_date()

    if relative_date == Timex.today() do
      "Today"
    else
      Timex.to_datetime(utc_datetime, time_zone)
      |> Timex.format!("%d %b, %Y", :strftime)
    end
  end

  def readable_time(%{:when => utc_datetime, :time_zone => time_zone}) do
    Timex.to_datetime(utc_datetime, time_zone)
    |> Timex.format!("%-I:%M %P", :strftime)
  end

  def meeting_in_progress?(%{:when => utc_datetime, :duration => duration}) do
    lower_bound = Timex.compare(Timex.now(), Timex.shift(utc_datetime, minutes: -10)) >= 0
    upper_bound = Timex.compare(Timex.now(), Timex.shift(utc_datetime, minutes: duration)) == -1

    lower_bound and upper_bound
  end

  def meeting_ended?(%{:when => utc_datetime, :duration => duration}) do
    Timex.compare(Timex.now(), Timex.shift(utc_datetime, minutes: duration)) >= 0
  end

  def recordings_for_meeting(recordings, %{meeting_id: meeting_id}) do
    recordings
    |> Enum.filter(&(to_string(&1.meeting_id) == meeting_id))
  end

  defp join_url(meeting, user_info) do
    case BbbApi.join_url(meeting.meeting_id, user_info, %{
           name: meeting.meeting_name,
           record: true,
           presentation_url: meeting.presentation_url,
           autoStartRecording: meeting.auto_start_recording,
           webcamsOnlyForModerator: meeting.webcams_only_for_moderator,
           muteOnStart: meeting.mute_on_start
         }) do
      {:ok, join_url} ->
        URI.encode_www_form(join_url)

      {:error, _} ->
        ""
    end
  end

  def google_cal_link(meeting, user_info) do
    start =
      Timex.to_datetime(meeting.when, meeting.time_zone)
      |> Timex.format!("%Y%m%dT%H%M00", :strftime)

    fin =
      Timex.to_datetime(meeting.when, meeting.time_zone)
      |> Timex.shift(minutes: meeting.duration)
      |> Timex.format!("%Y%m%dT%H%M00", :strftime)

    "https://www.google.com/calendar/event?" <>
      "action=TEMPLATE" <>
      "&dates=#{start}%2F#{fin}" <>
      "&ctz=#{meeting.time_zone}" <>
      "&text=#{meeting.meeting_name}" <>
      case join_url(meeting, user_info) do
        "" ->
          ""

        link ->
          "&details=<a+href=\"#{link}\">click here</a>+to+join+#{meeting.meeting_name}%0A%0Aalternative+link:+#{
            link
          }"
      end
  end

  def outlook_link(meeting, user_info) do
    start =
      Timex.to_datetime(meeting.when, meeting.time_zone)
      |> Timex.format!("%Y%m%dT%H%M00", :strftime)

    fin =
      Timex.to_datetime(meeting.when, meeting.time_zone)
      |> Timex.shift(minutes: meeting.duration)
      |> Timex.format!("%Y%m%dT%H%M00", :strftime)

    "data:text/calendar;charset=utf8,BEGIN:VCALENDAR" <>
      "%0APRODID:-//Microsoft Corporation//Outlook 12.0 MIMEDIR//EN%0AVERSION:2.0%0AMETHOD:PUBLISH" <>
      "%0AX-MS-OLK-FORCEINSPECTOROPEN:TRUE" <>
      "%0ABEGIN:VTIMEZONE" <>
      "%0ATZID:#{meeting.time_zone}" <>
      "%0AEND:VTIMEZONE" <>
      "%0ABEGIN:VEVENT%0ACLASS:PUBLIC" <>
      "%0ADTEND;TZID=#{meeting.time_zone}:#{fin}" <>
      "%0ADTSTART;TZID=#{meeting.time_zone}:#{start}" <>
      "%0APRIORITY:5%0ASEQUENCE:0" <>
      "%0ASUMMARY;LANGUAGE=en-us:#{meeting.meeting_name}" <>
      "%0AURL:#{join_url(meeting, user_info)}" <>
      "%0ATRANSP:OPAQUE%0AX-MICROSOFT-CDO-BUSYSTATUS:BUSY%0AX-MICROSOFT-CDO-IMPORTANCE:1" <>
      "%0AX-MICROSOFT-DISALLOW-COUNTER:FALSE" <>
      "%0AX-MS-OLK-ALLOWEXTERNCHECK:TRUE%0AX-MS-OLK-AUTOFILLLOCATION:FALSE%0AX-MS-OLK-CONFTYPE:0%0ABEGIN:VALARM" <>
      "%0ATRIGGER:-PT1440M%0AACTION:DISPLAY%0ADESCRIPTION:Reminder%0AEND:VALARM%0AEND:VEVENT%0AEND:VCALENDAR%0A"
  end
end
