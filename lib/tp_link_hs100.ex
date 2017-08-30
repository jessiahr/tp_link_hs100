defmodule TpLinkHs100 do
  @moduledoc """
  Application for controlling tp-link outlets
  """

  defdelegate devices, to: TpLinkHs100.Switch
  defdelegate start_link, to: TpLinkHs100.Switch
  defdelegate on(id), to: TpLinkHs100.Switch
  defdelegate off(id), to: TpLinkHs100.Switch
end
