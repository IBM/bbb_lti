defmodule BbbLti.Clients.CredentialAdmin do
  def index(_) do
    [
      id: nil,
      client_id: nil,
      client_secret: %{
        name: "Client Secret",
        value: &String.duplicate("*", String.length(&1.client_secret))
      },
      inserted_at: nil,
      updated_at: nil
    ]
  end
end
