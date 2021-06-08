defmodule BbbLti.Repo.Migrations.AddAdditionalOptionsToMeetings do
  use Ecto.Migration

  def change do
    alter table(:meetings) do
      add :auto_start_recording, :boolean, default: true
      add :webcams_only_for_moderator, :boolean, default: false
      add :mute_on_start, :boolean, default: false
    end
  end
end
