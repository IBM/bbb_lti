defmodule BbbLtiWeb.Admin.LogoutButtonExtension do
  @moduledoc """
  Adds a 'Log Out' button to the Kaffy navbar, at the time of writing this
  Kaffy does not support custom links in the navbar.
  """
  use Phoenix.HTML
  alias BbbLtiWeb.Router.Helpers, as: Routes

  def javascripts(conn) do
    ~E"""
    <script>
      document.querySelector('.navbar-menu-wrapper').innerHTML += `
      <%= link "Log Out", to: Routes.login_path(conn, :delete), method: :delete, class: "navbar-logout-btn" %>
      `;

      document.querySelector('.sidebar ul.nav').innerHTML += `
      <li class="nav-item sidebar-logout-btn">
        <%= link "Log Out", method: :delete, to: Routes.login_path(conn, :delete), class: "nav-link" %>
      </li>
      `;
    </script>
    """
  end

  def stylesheets(_) do
    ~E"""
    <style>
    .navbar-menu-wrapper {
      justify-content: space-between !important;
      align-items: center !important;
    }

    .sidebar-logout-btn {
      display: none;
    }

    @media (max-width: 991px) {
      .navbar-logout-btn {
        display: none;
      }

      .sidebar-logout-btn {
        display: block;
      }
    }
    </style>
    """
  end
end
