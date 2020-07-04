defmodule BuyItWeb.WebhookController do
  use BuyItWeb, :controller
  import BuyIt.Utils
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

  def create(conn, %{
    "entry" => [
      %{
        "messaging" => [
          %{
            "postback" => %{
              "payload" => "GET_STARTED_PAYLOAD",
            },
            "sender" => %{"id" => psid},
          }
        ]
      }
    ],
    "object" => "page"
  }) do
    quick_reply_to_payload(psid)
    send_resp(conn, :ok, "")
  end
  def create(conn, %{
    "entry" => [
      %{
        "messaging" => [
          %{
            "message" => %{
              "quick_reply" => %{"payload" => payload_of_quick_reply},
            },
            "sender" => %{"id" => psid},
          }
        ]
      }
    ],
    "object" => "page"
  }) do
    handle_quick_payload(payload_of_quick_reply, psid)
    send_resp(conn, :ok, "")
  end
  def create(conn, params) do
    send_resp(conn, :ok, "")
  end
end