defmodule BbbLtiWeb.ToolControllerTest do
  use BbbLtiWeb.ConnCase

  alias BbbLti.Clients

  @client_params %{
    client_id: "@portal/some-id",
    client_secret: "some-random-string"
  }

  @good_lti_params %{
    "oauth_version" => "1.0",
    "oauth_consumer_key" => "%40portal%2Fsome-id",
    "oauth_signature_method" => "HMAC-SHA1",
    "oauth_timestamp" => "1589906139",
    "oauth_nonce" => "157227501959723723391589906139",
    "oauth_signature" => "i5xYxnvfdsIp8KTmn27HcCrQOBo=",
    "lis_person_sourcedid" => "Foo",
    "resource_link_id" => "281301",
    "roles" => "Instructor",
    "user_id" => "1"
  }

  @bad_signature %{
    "oauth_version" => "1.0",
    "oauth_consumer_key" => "%40portal%2Fsome-id",
    "oauth_signature_method" => "HMAC-SHA1",
    "oauth_timestamp" => "1525076552",
    "oauth_nonce" => "123",
    "oauth_signature" => "iyyQNRQyXTlpLJPJns3ireWjQxo",
    "lis_person_sourcedid" => "Foo",
    "resource_link_id" => "281301",
    "roles" => "Instructor",
    "user_id" => "1"
  }

  @missing_required_session_param %{
    "oauth_version" => "1.0",
    "oauth_consumer_key" => "%40portal%2Fsome-id",
    "oauth_signature_method" => "HMAC-SHA1",
    "oauth_timestamp" => "1525076552",
    "oauth_nonce" => "123",
    "oauth_signature" => "iyyQNRQyXTlpLJPJns3ireWjQxo",
    "lis_person_sourcedid" => "Foo",
    "resource_link_id" => "281301",
    "roles" => "Instructor"
  }

  describe "#validate_lti:" do
    test "good LTI params", %{conn: conn} do
      Clients.create_credential(@client_params)
      conn = post(conn, Routes.tool_path(conn, :validate_lti, @good_lti_params))
      assert html_response(conn, 302)
    end

    test "bad LTI signature", %{conn: conn} do
      Clients.create_credential(@client_params)
      conn = post(conn, Routes.tool_path(conn, :validate_lti, @bad_signature))
      assert html_response(conn, 400) =~ "The provided signature is incorrect"
    end

    test "missing required session param (user_id)", %{conn: conn} do
      Clients.create_credential(@client_params)
      conn = post(conn, Routes.tool_path(conn, :validate_lti, @missing_required_session_param))

      assert html_response(conn, 400) =~
               "One or more parameters required to establish a user session are missing."
    end

    test "client does not have credentials - good params", %{conn: conn} do
      conn = post(conn, Routes.tool_path(conn, :validate_lti, @good_lti_params))
      assert html_response(conn, 403) =~ "Client secret could not be verified."
    end

    test "client does not have credentials - bad params", %{conn: conn} do
      conn = post(conn, Routes.tool_path(conn, :validate_lti, @bad_signature))
      assert html_response(conn, 403) =~ "Client secret could not be verified."
    end
  end
end
