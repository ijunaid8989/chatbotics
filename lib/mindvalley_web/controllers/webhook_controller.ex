defmodule BuyItWeb.WebhookController do
  use BuyItWeb, :controller
  require Logger

  @verify_token Application.get_env(:mindvalley, :webhook_token)

  def verify(conn, %{"hub.challenge" => challenge, "hub.mode" => mode, "hub.verify_token" => verify_token }) do
    with true <- challenge != nil && mode != nil,
         true <- mode == "subscribe" && verify_token == @verify_token
    do
      Logger.info("WEBHOOK_VERIFIED")
      send_resp(conn, :ok, challenge)
    else
      _ -> send_resp(conn, :forbidden, "")
    end
  end
end