defmodule YandexDisk.Client do

  @typedoc """
    Token returned in ouath flow
  """
  @type token :: String.t

  @doc """
    Return client to use in all requests
  """
  @spec client(token) :: YandexDisk.client()
  def client(token) do
    middleware = [
      {Tesla.Middleware.BaseUrl, "https://cloud-api.yandex.net/v1"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [{"Authorization", "OAuth " <> token }]}
    ]

    Tesla.client(middleware)
  end
end