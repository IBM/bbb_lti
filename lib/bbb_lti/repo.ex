defmodule BbbLti.Repo do
  use Ecto.Repo,
    otp_app: :bbb_lti,
    adapter: Ecto.Adapters.Postgres
end
