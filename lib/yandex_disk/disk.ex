defmodule YandexDisk.Disk do
  @doc """
    Get info about free space etc
  ## Examples
      iex> YandexDisk.Disk.about(client)
      {:ok,
       %{
         "is_paid" => true,
         "max_file_size" => 53687091200,
         "revision" => 1563732540947439,
         "system_folders" => %{
           "applications" => "disk:/Приложения",
           "downloads" => "disk:/Загрузки/",
           "facebook" => "disk:/Социальные сети/Facebook",
           "google" => "disk:/Социальные сети/Google+",
           "instagram" => "disk:/Социальные сети/Instagram",
           "mailru" => "disk:/Социальные сети/Мой Мир",
           "odnoklassniki" => "disk:/Социальные сети/Одноклассники",
           "photostream" => "disk:/Фотокамера/",
           "screenshots" => "disk:/Скриншоты/",
           "social" => "disk:/Социальные сети/",
           "vkontakte" => "disk:/Социальные сети/ВКонтакте"
         },
         "total_space" => 1110249046016,
         "trash_size" => 16428206,
         "unlimited_autoupload_enabled" => false,
         "used_space" => 375956518602,
         "user" => %{
           "country" => "bg",
           "display_name" => "test",
           "login" => "test",
           "uid" => "1111111111"
         }
       }}
  See: 
    * https://yandex.ru/dev/disk/api/reference/capacity-docpage/
  """
  @spec about(YandexDisk.client()) :: {:ok, YandexDisk.disk_info()}
  def about(client) do
    {:ok, %Tesla.Env{body: body}} = Tesla.get(client, "/disk")
    {:ok, body}
  end

  @doc """
    Get info about resource metadata
  ## Examples
      iex> YandexDisk.Disk.metadata(client, yandex_path: "disk:/test/test11.mp4",
                                            fields: "created, media_type, md5, name, revision, path, size")
      {:ok,
       %{
         "created" => "2019-07-13T19:43:12+00:00",
         "md5" => "46243e8d863a41077e242cfa1abca138",
         "media_type" => "video",
         "name" => "test11.mp4",
         "path" => "disk:/test/test11.mp4",
         "revision" => 1563732540947439,
         "size" => 5437077
       }}
  See: 
    * https://yandex.ru/dev/disk/api/reference/meta-docpage/
  """
  @spec metadata(YandexDisk.client(), Keyword.t()) :: {:ok, YandexDisk.info} | YandexDisk.error_result()
  def metadata(client, args \\ []) do
    {yandex_path, args}       = Keyword.pop(args, :yandex_path) 

    query = Keyword.merge(args, [path: yandex_path])
    {:ok, %Tesla.Env{body: body}} = Tesla.get(client, "/disk/resources", query: query)
    case body do
      %{"error" => error, "description" => description} ->
        {:error, error, description}
      info -> 
        {:ok, info}
    end
  end

  @doc """
    Get info about operation
  ## Examples
      iex> YandexDisk.Disk.operation_status(client, "xxxxxx")
      {:ok, %{"status" => "in-progress"}}
  See: 
    * https://yandex.ru/dev/disk/api/reference/operations-docpage/
  """
  @spec operation_status(YandexDisk.client(), String.t()) :: {:ok, YandexDisk.info} | YandexDisk.error_result()
  def operation_status(client, operation_id) do
    {:ok, %Tesla.Env{body: body}} = Tesla.get(client, "/disk/operations/#{operation_id}")
    case body do
      %{"error" => error, "description" => description} ->
        {:error, error, description}
      info -> 
        {:ok, info}
    end
  end


end