defmodule YandexDisk.Auth do
  @typedoc """
    Client Id of oauth app
  """
  @type client_id :: String.t

  @typedoc """
    Outh url used for authorization of app
  """
  @type outh_url :: String.t

  @doc """
    Generate url to be used for auth/getting token
  """
  @spec generate_url(client_id) :: outh_url
  def generate_url(client_id) do
    args = [
      response_type: "token",
      client_id: client_id,
      device_id: UUID.uuid4()
    ]
    Tesla.build_url("https://oauth.yandex.ru/authorize", args)
  end 
end