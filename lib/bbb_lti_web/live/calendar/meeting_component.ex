defmodule BbbLtiWeb.MeetingComponent do
  import BbbLtiWeb.Helpers.MeetingHelper
  use Phoenix.LiveComponent
  use Phoenix.HTML
  use Timex
  alias BbbLtiWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ~L"""
    <div class="min-w-0 flex-1 py-2 xl:px-4 grid grid-cols-3 gap-4">
      <div class="col-span-2">
          <p class="font-medium text-gray-800 truncate"><%= @meeting.meeting_name %><span class="text-sm font-normal text-gray-500"> - <%= @meeting.duration %> mins</span></p>
          <p class="flex text-sm items-top space-x-1 text-gray-900">
          <svg class="h-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
          </svg>
          <time><%= readable_date(@meeting) %></time>
          </p>
          <p class="flex text-sm items-top space-x-1 text-gray-900">
          <svg class="h-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <span><%= readable_time(@meeting) %><span class="text-gray-500"> <%= @meeting.time_zone %></span></span>
          </p>
      </div>
      <div class="flex items-center">
          <%= if meeting_in_progress?(@meeting) do %>
          <%= link "Join Now", to: Routes.meeting_path(@socket, :show, @meeting), target: "_blank", class: "bg-green-500 hover:bg-green-600 font-semibold text-white py-2 px-1 lg:px-4 border border-green-400 hover:border-transparent rounded" %>
          <% else %>
          <p class="text-sm"><%= relative_time(@meeting) %></p>
          <% end %>
      </div>
    </div>
    """
  end
end
