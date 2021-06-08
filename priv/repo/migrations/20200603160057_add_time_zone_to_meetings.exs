defmodule BbbLti.Repo.Migrations.AddTimeZoneToMeetings do
  use Ecto.Migration

  def change do
    alter table(:meetings) do
      add :time_zone, :string
    end
  end
end
