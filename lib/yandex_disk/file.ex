defmodule YandexDisk.File do
  defdelegate metadata(client, args), to: YandexDisk.Disk

  @doc """
    Get list of all files
  ## Examples
      iex> YandexDisk.File.index(client, limit: 3, fields: "items.name, items.media_type")
      {:ok, 0,
       [
         %{"media_type" => "compressed", "name" => "DICOM.zip"},
         %{"media_type" => "audio", "name" => "IM1"},
         %{"media_type" => "audio", "name" => "IM101"}
       ]}
  See: 
    * [Official docs](https://yandex.ru/dev/disk/api/reference/all-files-docpage/)
  """

  @spec index(YandexDisk.client(), Keyword.t()) ::
          {:ok, offset :: integer, YandexDisk.info()} | YandexDisk.error_result()
  def index(client, args \\ []) do
    query = Keyword.merge([limit: 20], args)

    {:ok, %Tesla.Env{body: body}} = Tesla.get(client, "/disk/resources/files", query: query)

    case body do
      %{"error" => error, "description" => description} ->
        {:error, error, description}

      %{"items" => items, "offset" => offset} ->
        {:ok, offset, items}
    end
  end

  @doc """
    Get recent files
  ## Examples
      iex>  YandexDisk.File.recent(client, limit: 3, media_type: "video", fields: "items.name, items.md5")
      {:ok, [%{"md5" => "46243e8d863a41077e242cfa1abca138", "name" => "test11.mp4"}]}

      iex>  YandexDisk.File.recent(client, limit: 3, fields: "items.name, items.md5")
      {:ok,
         [
           %{
             "md5" => "847b40a8802815fe4305675d85cd7700",
             "name" => "NVR_Camera 1_01_20190719071122.264"
           },
           %{
             "md5" => "01273a2910a9a578b112471602762749",
             "name" => "NVR_Camera 1_01_20190719071041.264"
           },
           %{
             "md5" => "a987e7b4e894e5406e118180a92e1512",
             "name" => "NVR_Camera 1_01_20190719071001.264"
           }
         ]}
  See: 
    * [Official docs](https://yandex.ru/dev/disk/api/reference/recent-upload-docpage/)
  """

  @spec recent(YandexDisk.client(), Keyword.t()) ::
          {:ok, YandexDisk.info()} | YandexDisk.error_result()
  def recent(client, args \\ []) do
    query = Keyword.merge([limit: 20], args)

    {:ok, %Tesla.Env{body: body}} =
      Tesla.get(client, "/disk/resources/last-uploaded", query: query)

    case body do
      %{"error" => error, "description" => description} ->
        {:error, error, description}

      %{"items" => items} ->
        {:ok, items}
    end
  end

  @doc """
    Upload file to yandex disk
  ## Examples
      iex>  YandexDisk.File.create(client, yandex_path: "disk:/test/test11_001.mp4", file: "/private/tmp/test11.mp4")
      {:ok,
       %{
         "href" => "https://uploader2o.disk.yandex.net:443/upload-target/20190721T171019.178.utd.2qnk7i2o1a71pt1gi51vm6f1d-k2o.29535254",
         "method" => "PUT",
         "operation_id" => "d49adcad60fa0727bf2b8607289a22271961d1e883bbe2041c5c3902758ce27d",
         "templated" => false
       }}
      iex>  YandexDisk.File.create(client, yandex_path: "disk:/test/test11_001.mp4", file: "/private/tmp/test11.mp4")
      {:error, "DiskResourceAlreadyExistsError", "Resource "disk:/test/test11_001.mp4" already exists."}

      iex> YandexDisk.File.create(client, yandex_path: "disk:/test/test11_001.mp4", file: "/private/tmp/test11.mp4", overwrite: true)
      {:ok,
       %{
         "href" => "https://uploader10j.disk.yandex.net:443/upload-target/20190721T171800.768.utd.91am4kjo1bucv1s0b5am7ruze-k10j.11648544",
         "method" => "PUT",
         "operation_id" => "e6db5ed3880c1dc5e62a085f44d6d0b1eb20fa9a8d8d0404dc7275b8e197d431",
         "templated" => false
       }}
  See: 
    * [Official docs](https://yandex.ru/dev/disk/api/reference/upload-docpage/)
  """
  @spec create(YandexDisk.client(), Keyword.t()) ::
          YandexDisk.success_result_info() | YandexDisk.error_result()
  def create(client, args) when not is_bitstring(args) do
    {path, args} = Keyword.pop(args, :yandex_path)
    {file, args} = Keyword.pop(args, :file)

    query = Keyword.merge(args, path: path)

    case obtain_upload_url(client, query) do
      {:error, error, description} ->
        {:error, error, description}

      {:ok, data} ->
        case create_request(data["href"], file) do
          {:ok} -> {:ok, data}
          {:error, error} -> {:error, error}
        end
    end
  end

  defp create_request(nil, file) when is_bitstring(file) do
    {:error, "File exists. Use overide param to force overide"}
  end

  defp create_request(upload_url, file) when is_bitstring(file) do
    file_stream = File.stream!(file, [], 2048)

    case HTTPoison.request(:put, upload_url, {:stream, file_stream}, [], []) do
      {:ok, %HTTPoison.Response{status_code: 201}} ->
        {:ok}

      {:ok, %HTTPoison.Response{status_code: 202}} ->
        {:ok}

      {:ok, %HTTPoison.Response{status_code: 412}} ->
        {:error, "Precondition Failed"}

      {:ok, %HTTPoison.Response{status_code: 413}} ->
        {:error, "Payload Too Large"}

      {:ok, %HTTPoison.Response{status_code: 500}} ->
        {:error, "Internal Server Error"}

      {:ok, %HTTPoison.Response{status_code: 503}} ->
        {:error, "Service Unavailable"}

      {:ok, %HTTPoison.Response{status_code: 507}} ->
        {:error, "Insufficient Storage"}
        
      {:error, %HTTPoison.Error{id: nil, reason: :timeout}} ->
        {:error, :timeout}
    end
  end

  @doc """
    Download file from yandex disk
  ## Examples
      iex>  YandexDisk.File.create(client, yandex_path: "disk:/test/test11_001.mp4", file: "/private/tmp/test11.mp4")
      {:ok,
       %{
         "href" => "https://uploader2o.disk.yandex.net:443/upload-target/20190721T171019.178.utd.2qnk7i2o1a71pt1gi51vm6f1d-k2o.29535254",
         "method" => "PUT",
         "operation_id" => "d49adcad60fa0727bf2b8607289a22271961d1e883bbe2041c5c3902758ce27d",
         "templated" => false
       }}
      iex>  YandexDisk.File.create(client, yandex_path: "disk:/test/test11_001.mp4", file: "/private/tmp/test11.mp4")
      {:error, "DiskResourceAlreadyExistsError", "Resource "disk:/test/test11_001.mp4" already exists."}

      iex> YandexDisk.File.create(client, yandex_path: "disk:/test/test11_001.mp4", file: "/private/tmp/test11.mp4", overwrite: true)
      {:ok,
       %{
         "href" => "https://uploader10j.disk.yandex.net:443/upload-target/20190721T171800.768.utd.91am4kjo1bucv1s0b5am7ruze-k10j.11648544",
         "method" => "PUT",
         "operation_id" => "e6db5ed3880c1dc5e62a085f44d6d0b1eb20fa9a8d8d0404dc7275b8e197d431",
         "templated" => false
       }}
  See: 
    * [Official docs](https://yandex.ru/dev/disk/api/reference/content-docpage/)
  """
  @spec get(YandexDisk.client(), yandex_path: String.t(), file: String.t()) :: {:ok}
  def get(client, yandex_path: yandex_path, file: file) do
    download_url = obtain_download_url(client, path: yandex_path)
    get(download_url: download_url, file: file)
  end

  defp get(download_url: download_url, file: file_path) do
    File.open!(file_path, [:write], fn file ->
      Downstream.get(download_url, file)
    end)

    {:ok}
  end

  @doc """
    Update metainfo about file
  ## Examples
      iex> YandexDisk.File.update(client, yandex_path: "disk:/test/test11_001.mp4", custom_properties: %{:foo => :bar}, fields: "custom_properties, path")
      {:ok,
       %{
         "custom_properties" => %{"foo" => "bar"},
         "path" => "disk:/test/test11_001.mp4"
       }}

       iex> YandexDisk.File.update(client, yandex_path: "disk:/test/not_existing.mp4", custom_properties: %{:foo => :bar})
       { :error, "DiskNotFoundError", "Resource not found." }
  See: 
    * [Official docs](https://yandex.ru/dev/disk/api/reference/meta-add-docpage/)
  """
  @spec update(YandexDisk.client(), Keyword.t()) ::
          {:ok, YandexDisk.info()} | YandexDisk.error_result()
  def update(client, args) do
    {yandex_path, args} = Keyword.pop(args, :yandex_path)
    {custom_properties, args} = Keyword.pop(args, :custom_properties)

    query = Keyword.merge(args, path: yandex_path)

    {:ok, %Tesla.Env{body: body}} =
      Tesla.patch(client, "/disk/resources", %{custom_properties: custom_properties}, query: query)

    case body do
      %{"error" => error, "description" => description} ->
        {:error, error, description}

      info ->
        {:ok, info}
    end
  end

  @doc """
    Copy file from one folder to another. Return error if destination file already exists.
    Pass `overwrite: true` to overwrite existing file.
  ## Examples
      iex> YandexDisk.File.copy(client, from: "disk:/test/test11.mp4", to: "disk:/test/test_folder4/test11.mp4")
      {:ok,
       %{
         "href" => "https://cloud-api.yandex.net/v1/disk/resources?path=disk%3A%2Ftest%2Ftest_folder4%2Ftest11.mp4",
         "method" => "GET",
         "templated" => false
       }}

       iex> YandexDisk.File.copy(client, from: "disk:/test/test11.mp4", to: "disk:/test/test_folder4/test11.mp4")
       {:error, "DiskResourceAlreadyExistsError",
          "Resource "disk:/test/test_folder4/test11.mp4" already exists."}

       iex> YandexDisk.File.copy(client, from: "disk:/test/test11.mp4", to: "disk:/test/test_folder4/test11.mp4", overwrite: true)
       {:ok,
         %{
           "href" => "https://cloud-api.yandex.net/v1/disk/resources?path=disk%3A%2Ftest%2Ftest_folder4%2Ftest11.mp4",
           "method" => "GET",
           "templated" => false
         }}
  See: 
    * [Official docs](https://yandex.ru/dev/disk/api/reference/copy-docpage/)
  """
  @spec copy(YandexDisk.client(), Keyword.t()) ::
          {:ok, YandexDisk.info()} | YandexDisk.error_result()
  def copy(client, args) do
    {yandex_path, args} = Keyword.pop(args, :to)

    query = Keyword.merge(args, path: yandex_path)
    {:ok, %Tesla.Env{body: body}} = Tesla.post(client, "/disk/resources/copy", "", query: query)

    case body do
      %{"error" => error, "description" => description} ->
        {:error, error, description}

      info ->
        {:ok, info}
    end
  end

  @doc """
    Move file from one folder to another. Return error if destination file already exists.
    Pass `overwrite: true` to overwrite existing file.
  ## Examples
      iex> YandexDisk.Folder.move(client, from: "disk:/test/test_folder4", to: "disk:/test/test_folder6")
      {:ok,
       %{
         "href" => "https://cloud-api.yandex.net/v1/disk/operations/xxxxx",
         "method" => "GET",
         "templated" => false
       }}

       iex> YandexDisk.Folder.move(client, from: "disk:/test/test_folder4", to: "disk:/test/test_folder6")
       {:error, "DiskNotFoundError", "Resource not found."}
  See: 
    * [Official docs](https://yandex.ru/dev/disk/api/reference/copy-docpage/)
  """
  @spec move(YandexDisk.client(), Keyword.t()) ::
          {:ok, YandexDisk.info()} | YandexDisk.error_result()
  def move(client, args) do
    {yandex_path, args} = Keyword.pop(args, :to)

    query = Keyword.merge(args, path: yandex_path)
    {:ok, %Tesla.Env{body: body}} = Tesla.post(client, "/disk/resources/move", "", query: query)

    case body do
      %{"error" => error, "description" => description} ->
        {:error, error, description}

      info ->
        {:ok, info}
    end
  end

  @doc """
    Delete file. You can pass `permanently: true` to remove file totally. By default file is placed 
    into Trash.
  ## Examples
      iex> YandexDisk.File.destroy(client, yandex_path: "disk:/test/test11_001.mp4")
      { :ok, :ok }

      iex> YandexDisk.File.destroy(client, yandex_path: "disk:/test/not_existing.mp4")
      { :error, "DiskNotFoundError", "Resource not found." }
  See: 
    * [Official docs](https://yandex.ru/dev/disk/api/reference/delete-docpage/)
  """
  @spec destroy(YandexDisk.client(), Keyword.t()) ::
          {:ok, YandexDisk.url()} | {:ok, :ok} | YandexDisk.error_result()
  def destroy(client, args) do
    {path, args} = Keyword.pop(args, :yandex_path)
    query = Keyword.merge(args, path: path)

    {:ok, %Tesla.Env{body: body}} = Tesla.delete(client, "/disk/resources", query: query)

    case body do
      %{"error" => error, "description" => description} ->
        {:error, error, description}

      %{"href" => href} ->
        {:ok, href}

      "" ->
        {:ok, :ok}
    end
  end

  defp obtain_upload_url(client, query) do
    {:ok, %Tesla.Env{body: body}} = Tesla.get(client, "/disk/resources/upload", query: query)

    case body do
      %{"error" => error, "description" => description} ->
        {:error, error, description}

      info ->
        {:ok, info}
    end
  end

  defp obtain_download_url(client, args) do
    {:ok, %Tesla.Env{body: body}} = Tesla.get(client, "disk/resources/download", query: args)

    {:ok, %HTTPoison.Response{headers: headers}} =
      HTTPoison.request(:get, body["href"], "", [], follow_redirect: false)

    {_, location} = headers |> Enum.find(fn {x, _y} -> x == "Location" end)
    location
  end
end
