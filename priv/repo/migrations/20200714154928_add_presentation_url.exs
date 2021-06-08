defmodule BbbLti.Repo.Migrations.AddPresentationUrl do
  use Ecto.Migration

  def change do
    alter table(:meetings) do
      add :presentation_url, :string
    end
  end
end
