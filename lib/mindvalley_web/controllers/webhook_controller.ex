defmodule BuyItWeb.WebhookController do
  use BuyItWeb, :controller
  import BuyIt.Utils
  alias BuyIt.Steps
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
    Steps.save(psid, "GET_STARTED")
    set_typing(psid)
    spawn(fn -> quick_reply_to_payload(psid) end)
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
    Steps.save(psid, "ASKED_FOR_GOOD_READ_DATA", payload_of_quick_reply)
    set_typing(psid, "typing_on")
    spawn(fn -> handle_quick_payload(payload_of_quick_reply, psid) end)
    send_resp(conn, :ok, "")
  end
  def create(conn, %{
    "entry" => [
      %{
        "messaging" => [
          %{
            "message" => %{
              "is_echo" => true
            }
          }
        ]
      }
    ]
  }) do
    Logger.info("Resent the flow message.")
    send_resp(conn, :ok, "")
  end
  def create(conn, %{
    "entry" => [
      %{
        "messaging" => [
          %{
            "message" => %{
              "text" => message
            },
            "sender" => %{"id" => psid},
          }
        ]
      }
    ],
    "object" => "page"
  }) do
    set_typing(psid, "typing_on")
    Steps.get(psid)
    |> handle_random_message(psid, message)
    send_resp(conn, :ok, "")
  end
  def create(conn, params) do
    IO.inspect(params)
    send_resp(conn, :ok, "")
  end
end