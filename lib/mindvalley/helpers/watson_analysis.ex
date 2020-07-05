defmodule Buyit.WatsonAnalysis do

  @watson_key Application.get_env(:mindvalley, :watson_key)
  @watson_api Application.get_env(:mindvalley, :watson_api)

  def analyse(text) do
    model = %{
      confidence: 0,
      anger: 0,
      disgust: 0,
      joy: 0,
      relevance: 0,
      sentiments: []
    }
    body = Jason.encode!(%{
      "text" => text,
      "features" => %{
        "entities" => %{
          "emotion" => true,
          "sentiment" => true
        }
      }
    })
    headers = [{"Content-type", "application/json"}, {"Authorization", "Basic #{Base.encode64("apikey:#{@watson_key}")}"}]

    with {:ok, response} <- HTTPoison.post(@watson_api, body, headers, []),
         %HTTPoison.Response{status_code: 200, body: body} <- response,
         {:ok, data} <- Jason.decode(body)
    do
      data["entities"]
      |> Enum.reduce(model, fn entity, map ->
        %{
          "confidence" => confidence,
          "emotion" => %{
            "anger" => anger,
            "disgust" => disgust,
            "joy" => joy,
          },
          "relevance" => relevance,
          "sentiment" => sentiment,
        } = entity
        %{map |
          confidence: map.confidence + confidence,
          anger: map.anger + anger,
          disgust: map.disgust + disgust,
          joy: map.joy + joy,
          relevance: map.relevance + relevance,
          sentiments: map.sentiments ++ [sentiment]
        }
      end)
    else
      _ -> model
    end
  end
end