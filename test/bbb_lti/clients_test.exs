defmodule BbbLti.ClientsTest do
  use BbbLti.DataCase

  alias BbbLti.Clients

  describe "credentials" do
    alias BbbLti.Clients.Credential

    @valid_attrs %{"client_id" => "foo", "client_secret" => "bar"}
    @update_attrs %{
      client_id: "some updated client_id",
      client_secret: "some updated client_secret"
    }
    @invalid_attrs %{client_id: nil, client_secret: nil}

    def credential_fixture(attrs \\ %{}) do
      {:ok, credential} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Clients.create_credential()

      credential
    end

    test "list_credentials/0 returns all credentials" do
      credential = credential_fixture()
      assert Clients.list_credentials() == [credential]
    end

    test "get_credential!/1 returns the credential with given id" do
      credential = credential_fixture()
      assert Clients.get_credential!(credential.id) == credential
    end

    test "get_credential/1 returns the credential with given client_id" do
      credential = credential_fixture()
      assert Clients.get_credential(credential.client_id) == credential
    end

    test "get_client_secret/1 returns the client's secret" do
      credential = credential_fixture()
      assert Clients.get_client_secret(credential.client_id) == {:ok, credential.client_secret}
    end

    test "get_client_secret/1 returns error tuple with invalid client_id" do
      assert Clients.get_client_secret("foo") == {:error, :secret_not_found}
    end

    test "get_or_create/1 a client is created when it doesn't exist" do
      assert [] = Clients.list_credentials()
      assert {:ok, %Credential{} = cred} = Clients.get_or_create(@valid_attrs)
      assert cred.client_id == "foo"
      assert [item] = Clients.list_credentials()
      assert item == cred
    end

    test "get_or_create/1 a client is returned when it exists" do
      Clients.create_credential(@valid_attrs)
      assert [item] = Clients.list_credentials()
      assert {:ok, %Credential{} = cred} = Clients.get_or_create(@valid_attrs)
      assert cred.client_id == "foo"
      assert [item] = Clients.list_credentials()
      assert item == cred
    end

    test "get_or_create/1 missing fields" do
      assert {:error, %Ecto.Changeset{}} = Clients.get_or_create(%{"client_id" => "foo"})
    end

    test "create_credential/1 with valid data creates a credential" do
      assert {:ok, %Credential{} = credential} = Clients.create_credential(@valid_attrs)
      assert credential.client_id == "foo"
      assert credential.client_secret == "bar"
    end

    test "create_credential/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Clients.create_credential(@invalid_attrs)
    end

    test "update_credential/2 with valid data updates the credential" do
      credential = credential_fixture()

      assert {:ok, %Credential{} = credential} =
               Clients.update_credential(credential, @update_attrs)

      assert credential.client_id == "some updated client_id"
      assert credential.client_secret == "some updated client_secret"
    end

    test "update_credential/2 with invalid data returns error changeset" do
      credential = credential_fixture()
      assert {:error, %Ecto.Changeset{}} = Clients.update_credential(credential, @invalid_attrs)
      assert credential == Clients.get_credential!(credential.id)
    end

    test "delete_credential/1 deletes the credential" do
      credential = credential_fixture()
      assert {:ok, %Credential{}} = Clients.delete_credential(credential)
      assert_raise Ecto.NoResultsError, fn -> Clients.get_credential!(credential.id) end
    end

    test "change_credential/1 returns a credential changeset" do
      credential = credential_fixture()
      assert %Ecto.Changeset{} = Clients.change_credential(credential)
    end
  end
end
