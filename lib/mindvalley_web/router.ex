defmodule BuyItWeb.Router do
  use BuyItWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/v1", BuyItWeb do
    pipe_through :api

    get "/webhook", WebhookController, :verify
    post "/webhook", WebhookController, :create
  end
end
