defmodule BuyItWeb.Router do
  use BuyItWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BuyItWeb do
    pipe_through :api
  end
end
