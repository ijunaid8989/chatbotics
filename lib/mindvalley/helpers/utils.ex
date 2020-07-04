defmodule BuyIt.Utils do

  @profile_api Application.get_env(:mindvalley, :messenger_profile_api)
  @messages_api Application.get_env(:mindvalley, :messages)
  @page_token Application.get_env(:mindvalley, :page_token)
  @graph_api Application.get_env(:mindvalley, :graph)

  def set_get_started_button do
    body = Jason.encode!(%{
     "get_started" => %{
        "payload" => "GET_STARTED_PAYLOAD"
      }
    })
    headers = [{"Content-type", "application/json"}]
    HTTPoison.post(@profile_api <> "?access_token=" <> @page_token, body, headers, [])
  end

  def user_info(psid) do
    with {:ok, response} <- HTTPoison.get(@graph_api <> "/#{psid}?fields=first_name&access_token=" <> @page_token),
         %HTTPoison.Response{status_code: 200, body: body} <- response,
         {:ok, data} <- Jason.decode(body)
    do
      data["first_name"]
    else
      _ -> "Unknown"
    end
  end

  def general_reply(psid, message) do
    body = Jason.encode!(%{
      "messaging_type" => "RESPONSE",
      "recipient" => %{
        "id" => psid
      },
      "message" => %{
        "text" => message
      }
    })
    headers = [{"Content-type", "application/json"}]
    HTTPoison.post(@messages_api <> "?access_token=" <> @page_token, body, headers, [])
  end

  def handle_quick_payload("SEARCH_BY_NAME", psid), do: general_reply(psid, "Please enter name of the book.")
  def handle_quick_payload("SEARCH_BY_ID", psid), do: general_reply(psid, "Please enter the ID (Goodreads ID) of the book.")

  def quick_reply_to_payload(psid) do
    user_first_name = user_info(psid)
    body = Jason.encode!(%{
      "recipient" => %{
        "id" => psid
      },
      "messaging_type" => "RESPONSE",
      "message" => %{
        "text" => "Welcome #{user_first_name}, would you like to search books by name or by ID (Goodreads ID)?",
        "quick_replies" => [
          %{
            "content_type" => "text",
            "title" => "Name",
            "payload" => "SEARCH_BY_NAME",
          },
          %{
            "content_type" => "text",
            "title" => "ID (Goodreads ID)",
            "payload" => "SEARCH_BY_ID",
          }
        ]
      }
    })
    headers = [{"Content-type", "application/json"}]
    HTTPoison.post(@messages_api <> "?access_token=" <> @page_token, body, headers, [])
  end

  def handle_random_message("GET_STARTED", psid, _message) do
    quick_reply_to_payload(psid)
  end
  def handle_random_message("ASKED_FOR_GOOD_READ_DATA", psid, message) do
    IO.inspect(message)
    IO.inspect(psid)
  end
end
