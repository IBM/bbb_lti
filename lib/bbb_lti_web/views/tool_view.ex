defmodule BbbLtiWeb.ToolView do
  use BbbLtiWeb, :view

  @messages %{
    :secret_not_found =>
      "Client secret could not be verified. Please authenticate this LTI client and try again.",
    :unmatching_signatures =>
      "The provided signature is incorrect, please check your LTI credentials.",
    :incorrect_version => "Incorrect LTI version, please check your LTI credentials.",
    :duplicated_parameters =>
      "One or more of your parameters are duplicates, please check your LTI credentials.",
    :missing_required_parameters =>
      "One or more required parameters are missing, please check your LTI credentials.",
    :missing_required_session_parameters =>
      "One or more parameters required to establish a user session are missing.\
       Please ensure you are launching this tool from a validated LTI client in the live learning view\
       and ensure that user names are enabled to be passed into the tool.",
    :unsupported_parameters => "One or more of the parameters provided are unsopported."
  }

  @doc """
    parameter err - is an array which can contain 1 or more atoms
    i.e. [:unmatching_signatures, :incorrect_version]
  """
  def lti_err_message(err) when is_list(err) do
    Enum.map(err, fn msg ->
      @messages[msg]
    end)
  end

  def lti_err_message(err) when is_atom(err) do
    [@messages[err]]
  end
end
