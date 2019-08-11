defmodule YandexDisk do
  @moduledoc """
    Downloading and uploading are done using streams.

    `YandexDisk.File` - downloading/uploading files

    `YandexDisk.Folder` - folder manipulations

    `YandexDisk.PublicFile` - publish files to internet
    
    `YandexDisk.Trash` - manipulation with trash
  """
  @type client :: Tesla.Client.t()
  @type error_info :: String.t()
  @type error_description :: String.t()
  @type url :: String.t()
  @type local_path :: String.t()
  @type info :: map
  @type disk_info :: map

  @type error_result :: {:error, error_info, error_description} 
  @type success_result_url :: {:ok, url}
  @type success_result_info :: {:ok, info}

end
