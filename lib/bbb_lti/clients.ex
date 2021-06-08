defmodule BbbLti.Clients do
  @moduledoc """
  The Clients context.
  """

  import Ecto.Query, warn: false
  alias BbbLti.Repo

  alias BbbLti.Clients.Credential

  def list_credentials do
    Repo.all(Credential)
  end

  def get_credential!(id), do: Repo.get!(Credential, id)

  def get_credential(client_id), do: Repo.get_by(Credential, client_id: client_id)

  def get_client_secret(client_id) do
    case Repo.get_by(Credential, client_id: client_id) do
      %Credential{} = client -> {:ok, client.client_secret}
      nil -> {:error, :secret_not_found}
    end
  end

  def get_or_create(%{"client_id" => client_id} = params) do
    case Repo.get_by(Credential, client_id: client_id) do
      %Credential{} = credential -> {:ok, credential}
      nil -> create_credential(params)
    end
  end

  def create_credential(attrs \\ %{}) do
    %Credential{}
    |> Credential.changeset(attrs)
    |> Repo.insert()
  end

  def update_credential(%Credential{} = credential, attrs) do
    credential
    |> Credential.changeset(attrs)
    |> Repo.update()
  end

  def delete_credential(%Credential{} = credential) do
    Repo.delete(credential)
  end

  def change_credential(%Credential{} = credential, attrs \\ %{}) do
    Credential.changeset(credential, attrs)
  end
end
