defmodule BbbLti.Meetings.Meeting do
  use Ecto.Schema
  import Ecto.Changeset

  schema "meetings" do
    field :meeting_id, :string
    field :created_by, :string
    field :meeting_name, :string
    field :unit_id, :string
    field :when, :utc_datetime
    field :time_zone, :string
    field :duration, :integer, default: 60
    field :presentation_url, :string
    field :auto_start_recording, :boolean, default: true
    field :webcams_only_for_moderator, :boolean, default: false
    field :mute_on_start, :boolean, default: false
    field :time_zone_local, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(meeting, attrs) do
    meeting
    |> cast(attrs, [
      :unit_id,
      :created_by,
      :meeting_name,
      :when,
      :meeting_id,
      :time_zone,
      :duration,
      :presentation_url,
      :auto_start_recording,
      :webcams_only_for_moderator,
      :mute_on_start,
      :time_zone_local
    ])
    |> validate_required([
      :unit_id,
      :created_by,
      :meeting_name,
      :when,
      :meeting_id,
      :time_zone,
      :duration,
      :time_zone_local
    ])
    |> unique_constraint(:meeting_id)
    |> validate_format(
      :presentation_url,
      ~r/[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&\/\/=]*)/
    )
  end
end
