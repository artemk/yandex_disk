defmodule YandexDisk.Trash do
  @doc """
    Remove file from trash or clear trash totally.
  ## Examples
      iex> YandexDisk.Trash.clear(client, yandex_path: "test11_001.mp4")
      { :ok, :removed }

      iex> YandexDisk.Trash.clear(client, yandex_path: "test_folder4")
      { :ok, :removed }

      iex> YandexDisk.Trash.clear(client)
      { :ok, :removing }

      iex> YandexDisk.Trash.clear(client, yandex_path: "test_folder4")
      { :error, :no_resource }
  See: 
    * https://yandex.ru/dev/disk/api/reference/trash-delete-docpage/
  """
  @spec clear(YandexDisk.client(), Keyword.t()) :: {:ok, :removed} | {:ok, :removing} | {:error, :no_resource}
  def clear(client, args \\ []) do
    {path, args}  = Keyword.pop(args, :yandex_path)
    query         = Keyword.merge(args, [path: path])

    {:ok, %Tesla.Env{body: body, status: status}} = Tesla.delete(client, "/disk/trash/resources", query: query)

    case status do
      204 -> {:ok, :removed}
      202 -> {:ok, :removing}
      404 -> {:error, :no_resource}
    end
  end

  @doc """
    Restoring files or folders placed in trash
  ## Examples
      iex> YandexDisk.Trash.restore(client, yandex_path: "nvr")
      { :ok, :restoring }
  See: 
    * https://yandex.ru/dev/disk/api/reference/trash-restore-docpage/
  """
  @spec restore(YandexDisk.client(), Keyword.t()) :: {:ok, :restored} | {:ok, :restoring} | {:error, :no_resource}
  def restore(client, args \\ []) do
    {yandex_path, args}       = Keyword.pop(args, :yandex_path) 

    query = Keyword.merge(args, [path: yandex_path])
    {:ok, %Tesla.Env{body: body, status: status}} = Tesla.put(client, "/disk/trash/resources/restore", nil, query: query)
    case status do
      201 -> {:ok, :restored}
      202 -> {:ok, :restoring}
      404 -> {:error, :no_resource}
    end
  end
end