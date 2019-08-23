defmodule YandexDisk.PublicFile do
  @doc """
    Get list of public files
  ## Examples
      iex>  YandexDisk.PublicFile.index(client, fields: "items.mime_type, items.md5")
      {:ok, 0,
       [
         %{
           "md5" => "66fcbb369769cfd43f897d9f9171fbad",
           "mime_type" => "application/octet-stream"
         },
         %{
           "md5" => "3defac315e17c4550655705b9cb53cc9",
           "mime_type" => "application/pdf"
         },
         %{
           "md5" => "87abb909d4019c109275b6a5704b5ee9",
           "mime_type" => "application/x-zip-compressed"
         }
       ]}
  See: 
    * [Official docs](https://yandex.ru/dev/disk/api/reference/recent-public-docpage/)
  """

  @spec index(YandexDisk.client(), Keyword.t()) ::
          {:ok, offset :: integer, list} | YandexDisk.error_result()
  def index(client, args \\ []) do
    offset = Keyword.get(args, :offset, 0)
    query = Keyword.merge([type: "file"], args)

    {:ok, %Tesla.Env{body: body}} = Tesla.get(client, "/disk/resources/public", query: query)

    case body do
      %{"error" => error, "description" => description} ->
        {:error, error, description}

      %{"items" => items} ->
        {:ok, offset, items}
    end
  end

  @doc """
    Publish file to be accessed from internet
  ## Examples
    iex> YandexDisk.PublicFile.create(client, yandex_path:  "disk:/test/test11.mp4")
    { :ok, "https://cloud-api.yandex.net/v1/disk/resources?path=disk:/test/test11.mp4" }

    iex> {:ok, %{"public_url" => public_url}} = 
      YandexDisk.PublicFile.metadata(client, yandex_path: yandex_path, fields: "public_url")
    { :ok, %{"public_url" => "https://yadi.sk/i/OZ9eUNjLMZKlmA"} }

    iex> public_url
    "https://yadi.sk/i/OZ9eUNjLMZKlmA"
  See: 
    * [Official docs](https://yandex.ru/dev/disk/api/reference/publish-docpage/#publish)
  """
  @spec create(YandexDisk.client(), Keyword.t()) ::
          YandexDisk.success_result_url() | YandexDisk.error_result()
  def create(client, args) do
    {path, args} = Keyword.pop(args, :yandex_path)
    query = Keyword.merge(args, path: path)

    {:ok, %Tesla.Env{body: body}} =
      Tesla.put(client, "/disk/resources/publish", nil, query: query)

    case body do
      %{"error" => error, "description" => description} ->
        {:error, error, description}

      %{"href" => href} ->
        {:ok, href}
    end
  end

  @doc """
    Get metainfo about public file
  ## Examples
      iex>  YandexDisk.PublicFile.metadata(client, 
        public_key: "UloX3BvWzrrNDhOOy9G1JXxPdr+Di7EzKRQ2PX3+y02ssK5RalnfVi34kmMi9SzKq/J6bpmRyOJonT3VoXnDag==", 
        fields: "md5")
      { :ok, %{"md5" => "66fcbb369769cfd43f897d9f9171fbad"} }

       iex> YandexDisk.PublicFile.metadata(client, public_key: "UloX3BvWzrrNDhOOy9G1JXxPdr+Di7EzKRQ2PX3", yandex_path: "erere", fields: "md5")
       { :error, "DiskNotFoundError", "Resource not found." }
  See: 
    * [Official docs](https://yandex.ru/dev/disk/api/reference/public-docpage/#meta)
  """
  @spec metadata(YandexDisk.client(), Keyword.t()) ::
          {:ok, YandexDisk.info()} | YandexDisk.error_result()
  def metadata(client, args) do
    {yandex_path, args} = Keyword.pop(args, :yandex_path)

    query = Keyword.merge(args, path: yandex_path)
    {:ok, %Tesla.Env{body: body}} = Tesla.get(client, "/disk/public/resources", query: query)

    case body do
      %{"error" => error, "description" => description} ->
        {:error, error, description}

      info ->
        {:ok, info}
    end
  end

  @doc """
    Save to downloads. Will return error if you does not have Downloads folder.
  ## Examples    
      iex>  YandexDisk.PublicFile.save_to_downloads(client, 
        public_key: "UloX3BvWzrrNDhOOy9G1JXxPdr+Di7EzKRQ2PX3+y02ssK5RalnfVi34kmMi9SzKq/J6bpmRyOJonT3VoXnDag==", 
        name: "nvr1.264")
      { :error, "MethodNotAllowedError", "Method Not Allowed" }
  See: 
    * [Official docs](https://yandex.ru/dev/disk/api/reference/public-docpage/#save)
  """
  @spec save_to_downloads(YandexDisk.client(), Keyword.t()) ::
          {:ok, YandexDisk.info()} | YandexDisk.error_result()
  def save_to_downloads(client, args) do
    {yandex_path, args} = Keyword.pop(args, :yandex_path)

    query = Keyword.merge(args, path: yandex_path)

    {:ok, %Tesla.Env{body: body}} =
      Tesla.post(client, "/disk/resources/download", %{}, query: query)

    case body do
      %{"error" => error, "description" => description} ->
        {:error, error, description}

      info ->
        {:ok, info}
    end
  end

  @doc """
    Generate url for download
  ## Examples    
      iex>  YandexDisk.PublicFile.download_url(client, 
        public_key: "UloX3BvWzrrNDhOOy9G1JXxPdr+Di7EzKRQ2PX3+y02ssK5RalnfVi34kmMi9SzKq/J6bpmRyOJonT3VoXnDag==")
      {:ok,
       %{
         "href" => "https://downloader.disk.yandex.ru/disk/long_link",
         "method" => "GET",
         "templated" => false
       }}
  See: 
    * [Official docs](https://yandex.ru/dev/disk/api/reference/public-docpage/#download)
  """
  @spec download_url(YandexDisk.client(), Keyword.t()) ::
          {:ok, YandexDisk.info()} | YandexDisk.error_result()
  def download_url(client, args) do
    {yandex_path, args} = Keyword.pop(args, :yandex_path)

    query = Keyword.merge(args, path: yandex_path)

    {:ok, %Tesla.Env{body: body}} =
      Tesla.get(client, "/disk/public/resources/download", query: query)

    case body do
      %{"error" => error, "description" => description} ->
        {:error, error, description}

      info ->
        {:ok, info}
    end
  end

  @doc """
    Remove public file. File itself remains on disk. 
  ## Examples
    iex> YandexDisk.PublicFile.destroy(client, yandex_path: "disk:/test/test11.mp4")
    { :ok,  "https://cloud-api.yandex.net/v1/disk/resources?path=disk%3A%2Ftest%2Ftest11.mp4" }

    iex> {:ok, %{}} = YandexDisk.PublicFile.metadata(client, yandex_path: "disk:/test/test11.mp4", fields: "public_url")
  See: 
    * [Official docs](https://yandex.ru/dev/disk/api/reference/publish-docpage/#unpublish-q)
  """
  @spec destroy(YandexDisk.client(), Keyword.t()) ::
          YandexDisk.success_result_url() | YandexDisk.error_result()
  def destroy(client, args) do
    {path, args} = Keyword.pop(args, :yandex_path)
    query = Keyword.merge(args, path: path)

    {:ok, %Tesla.Env{body: body}} =
      Tesla.put(client, "/disk/resources/unpublish", nil, query: query)

    case body do
      %{"error" => error, "description" => description} ->
        {:error, error, description}

      %{"href" => href} ->
        {:ok, href}
    end
  end
end
