defmodule NimbleKitty.Repo do
  use Ecto.Repo,
    otp_app: :nimble_kitty,
    adapter: Ecto.Adapters.MyXQL
end
