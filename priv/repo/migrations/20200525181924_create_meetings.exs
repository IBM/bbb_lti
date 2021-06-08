defmodule BbbLti.Repo.Migrations.CreateMeetings do
  use Ecto.Migration

  def change do
    create table(:meetings) do
      add :unit_id, :string
      add :created_by, :string
      add :meeting_name, :string
      add :when, :utc_datetime
      add :meeting_id, :string

      timestamps()
    end
  end
end
