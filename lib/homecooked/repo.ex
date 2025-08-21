defmodule Homecooked.Repo do
  use Ecto.Repo,
    otp_app: :homecooked,
    adapter: Ecto.Adapters.Postgres

  use Paginator, limit: 10
end
