defmodule BuyIt.Steps do
  def save(psid, step), do: :dets.insert(:chat_flow, {psid, step})

  def get(psid) do
    [{_psid, step}] = :dets.lookup(:chat_flow, psid)
    step
  end
end