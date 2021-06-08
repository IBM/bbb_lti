defmodule BbbLti.Repo.Migrations.CreateCredentials do
  use Ecto.Migration

  def change do
    create table(:credentials) do
      add :client_id, :string, null: false
      add :client_secret, :string

      timestamps()
    end

    create unique_index(:credentials, [:client_id])
  end
end
