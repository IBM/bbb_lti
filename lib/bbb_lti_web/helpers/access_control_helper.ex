defmodule BbbLtiWeb.Helpers.AccessControlHelper do
  @instructor_role_titles ["instructor", "administrator", "staff", "admin"]

  def is_instructor?(%{role: role}), do: is_instructor?(role)

  def is_instructor?(role) when is_binary(role),
    do: String.downcase(role) in @instructor_role_titles
end
