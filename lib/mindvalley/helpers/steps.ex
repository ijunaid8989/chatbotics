defmodule BuyIt.Steps do
  def save(psid, step), do: :dets.insert(:chat_flow, {psid, step, []})
  def save(psid, step, "SEARCH_BY_NAME" = payload), do: :dets.insert(:chat_flow, {psid, step, [payload]})
  def save(psid, step, "SEARCH_BY_ID" = payload), do: :dets.insert(:chat_flow, {psid, step, [payload]})

  def get(psid) do
    [{_psid, step, payload}] = :dets.lookup(:chat_flow, psid)
    {step, payload}
  end
end