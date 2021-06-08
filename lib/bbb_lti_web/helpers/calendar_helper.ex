defmodule BbbLtiWeb.Helpers.CalendarHelper do
  def meetings_for_day(meetings, day, user_tz) do
    meetings
    |> Enum.filter(&(&1.when |> Timex.to_datetime(user_tz) |> same_day?(day)))
  end

  defp same_day?(d1, d2) do
    Map.take(d1, [:year, :month, :day]) == Map.take(d2, [:year, :month, :day])
  end
end
