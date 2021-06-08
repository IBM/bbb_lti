defmodule BbbLtiWeb.CalendarDayComponent do
  use Phoenix.LiveComponent
  use Timex

  def render(assigns) do
    assigns = Map.put(assigns, :day_class, day_class(assigns))

    ~L"""
    <td phx-click="pick-date" phx-value-date="<%= Timex.format!(@day, "%Y-%m-%d", :strftime) %>" class="<%= @day_class %>">
      <p class="p-2">
        <%= Timex.format!(@day, "%d", :strftime) %>
      </p>
      <%= meetings_overview(assigns) %>
    </td>
    """
  end

  defp day_class(assigns) do
    cond do
      today?(assigns) ->
        "align-top text-xs h-16 sm:h-24 w-28 border border-gray-200 bg-indigo-200 hover:bg-indigo-400 cursor-pointer p-0 hover:text-white"

      current_date?(assigns) ->
        "align-top text-xs h-16 sm:h-24 w-28 text-gray-600 border border-gray-200 bg-blue-100 cursor-pointer p-0"

      other_month?(assigns) ->
        "align-top text-xs h-16 sm:h-24 w-28 text-gray-400 border border-gray-200 bg-gray-200 cursor-not-allowed p-0"

      true ->
        "align-top text-xs h-16 sm:h-24 w-28 text-gray-600 border border-gray-200 bg-white hover:bg-gray-50 cursor-pointer p-0"
    end
  end

  defp current_date?(assigns) do
    Map.take(assigns.day, [:year, :month, :day]) ==
      Map.take(assigns.current_date, [:year, :month, :day])
  end

  defp today?(assigns) do
    Map.take(assigns.day, [:year, :month, :day]) == Map.take(Timex.now(assigns.user_tz), [:year, :month, :day])
  end

  defp other_month?(assigns) do
    Map.take(assigns.day, [:year, :month]) != Map.take(assigns.current_date, [:year, :month])
  end

  defp meetings_overview(assigns) do
    ~L"""
    <%= if length(assigns.meetings) > 0 do %>
      <p class="bg-blue-50 px-2 py-1 text-black">
        <%= if length(assigns.meetings) > 1 do %>
          <%= length(assigns.meetings) %> Sessions
        <% else %>
          <%= List.first(assigns.meetings).meeting_name %>
        <% end %>
      </p>
    <% end %>
    """
  end
end
