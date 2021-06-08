defmodule BbbLtiWeb.CalendarLive do
  import BbbLtiWeb.Helpers.CalendarHelper
  import BbbLtiWeb.Helpers.MeetingHelper
  use Phoenix.LiveView
  use Timex

  alias BbbLti.Meetings

  @week_start_at :sun

  def mount(_params, %{"current_user" => %{unit_id: unit_id}}, socket) do
    current_date = Timex.now(get_user_timezone(socket))
    meetings = Meetings.list_meetings(unit_id)

    assigns = [
      conn: socket,
      user_tz: get_user_timezone(socket),
      current_date: current_date,
      meetings: meetings,
      day_names: day_names(@week_start_at),
      week_rows: week_rows(current_date)
    ]

    {:ok, assign(socket, assigns)}
  end

  defp get_user_timezone(socket) do
    case Phoenix.LiveView.get_connect_params(socket) do
      %{"user_tz" => user_tz} -> user_tz
      _ -> "UTC"
    end
  end

  def handle_event("prev-month", _, socket) do
    current_date = Timex.shift(socket.assigns.current_date, months: -1)

    assigns = [
      current_date: current_date,
      week_rows: week_rows(current_date)
    ]

    {:noreply, assign(socket, assigns)}
  end

  def handle_event("next-month", _, socket) do
    current_date = Timex.shift(socket.assigns.current_date, months: 1)

    assigns = [
      current_date: current_date,
      week_rows: week_rows(current_date)
    ]

    {:noreply, assign(socket, assigns)}
  end

  def handle_event("pick-date", %{"date" => date}, socket) do
    current_date = Timex.parse!(date, "{YYYY}-{0M}-{D}")

    assigns = [
      current_date: current_date,
      week_rows: week_rows(current_date) # TODO: only send this when necessary
    ]

    {:noreply, assign(socket, assigns)}
  end

  defp day_names(:sun), do: [7, 1, 2, 3, 4, 5, 6] |> Enum.map(&Timex.day_shortname/1)
  defp day_names(_), do: [1, 2, 3, 4, 5, 6, 7] |> Enum.map(&Timex.day_shortname/1)

  defp week_rows(current_date) do
    first =
      current_date
      |> Timex.beginning_of_month()
      |> Timex.beginning_of_week(@week_start_at)

    last =
      current_date
      |> Timex.end_of_month()
      |> Timex.end_of_week(@week_start_at)

    Interval.new(from: first, until: last)
    |> Enum.map(& &1)
    |> Enum.chunk_every(7)
  end
end
