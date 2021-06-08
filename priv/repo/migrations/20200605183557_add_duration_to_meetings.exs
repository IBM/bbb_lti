defmodule BbbLti.Repo.Migrations.AddDurationToMeetings do
  use Ecto.Migration

  def change do
    alter table(:meetings) do
      add :duration, :integer, default: 60
    end
  end
end
