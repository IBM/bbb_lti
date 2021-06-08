defmodule BbbLti.Clients.Credential do
  use Ecto.Schema
  import Ecto.Changeset

  schema "credentials" do
    field :client_id, :string
    field :client_secret, :string

    timestamps()
  end

  @doc false
  def changeset(credential, attrs) do
    credential
    |> cast(attrs, [:client_id, :client_secret])
    |> validate_required([:client_id, :client_secret])
    |> unique_constraint(:client_id)
  end
end
