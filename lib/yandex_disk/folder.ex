defmodule YandexDisk.Folder do
  @doc """
    Creates folder on yandex disk. To force create full path, pass
    `force: true`.
  ## Examples
      iex> YandexDisk.Folder.create(client, yandex_path: "disk:/test/test_folder3")
      { :ok, "https://cloud-api.yandex.net/v1/disk/resources?path=disk%3A%2Ftest%2Ftest_folder3" }

      iex> YandexDisk.Folder.create(client, yandex_path: "disk:/test/test_folder1/test_folder2/test_folder3", force: true)
      { :ok, "disk:/test/test_folder4/test_folder14" }
  See: 
    * [Official docs](https://yandex.ru/dev/disk/api/reference/create-folder-docpage/)
  """
  @spec create(YandexDisk.client(), Keyword.t()) ::
          {:ok, YandexDisk.url()} | YandexDisk.error_result()
  def create(client, yandex_path: "disk:"), do: {:ok, "disk:/"}

  def create(client, args) do
    {path, args} = Keyword.pop(args, :yandex_path)
    {force, args} = Keyword.pop(args, :force)
    query = Keyword.merge(args, path: path)

    {:ok, %Tesla.Env{body: body}} = Tesla.put(client, "/disk/resources", nil, query: query)

    case body do
      %{"error" => "DiskPathDoesntExistsError"} ->
        if !!force do
          String.split(path, "/")
          |> Enum.drop(1)
          |> Enum.reduce("disk:", fn el, acc ->
            path = Path.join([acc, el])
            YandexDisk.Folder.create(client, Keyword.put(args, :yandex_path, path))
            path
          end)

          {:ok, path}
        end

      %{"error" => error, "description" => description} ->
        {:error, error, description}

      %{"href" => href} ->
        {:ok, href}
    end
  end

  @doc """
    Update metainfo about folder
  ## Examples
      iex> YandexDisk.Folder.update(client, yandex_path: "disk:/test/test_folder4/test_folder14", custom_properties: %{ :foo => :bar })
      { :ok,
       %{
         "comment_ids" => %{
           "private_resource" => "475750211:43029ae18a15e545b9422843e0f1a990478b46f71335ddb053bcd24adfae66ab",
           "public_resource" => "475750211:43029ae18a15e545b9422843e0f1a990478b46f71335ddb053bcd24adfae66ab"
         },
         "created" => "2019-07-21T11:17:06+00:00",
         "custom_properties" => %{ "foo" => "bar" },
         "exif" => %{ },
         "modified" => "2019-07-21T11:17:06+00:00",
         "name" => "test_folder14",
         "path" => "disk:/test/test_folder4/test_folder14",
         "resource_id" => "475750211:43029ae18a15e545b9422843e0f1a990478b46f71335ddb053bcd24adfae66ab",
         "revision" => 1563707826277734,
         "type" => "dir"
       } }
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
        {:error, error}

      info ->
        {:ok, info}
    end
  end

  @doc """
    Copy folder from one folder to another. Return error if destination folder already exists.
    Pass `overwrite: true` to overwrite existing file.
  ## Examples
      iex> YandexDisk.Folder.copy(client, from: "disk:/test/test_folder4", to: "disk:/test/test_folder5")
      { :ok,
       %{
         "href" => "https://cloud-api.yandex.net/v1/disk/operations/3daee0f4eb290e9461b88c89fb4dcd78a8ce01aa595e23753647c96abe009e36",
         "method" => "GET",
         "templated" => false
       } }

       iex> YandexDisk.Folder.copy(client, from: "disk:/test/test_folder4", to: "disk:/test/test_folder5")
       { :error, "DiskResourceAlreadyExistsError",
         "Resource "disk:/test/test_folder5" already exists." }
  
       iex> YandexDisk.Folder.copy(client, from: "disk:/test/test_folder4444", to: "disk:/test/test_folder5555")
       { :error, "DiskNotFoundError", "Resource not found." }

       iex> YandexDisk.Folder.copy(client, from: "disk:/test/test_folder4", to: "disk:/test/test_folder5", overwrite: true)
       { :ok,
       %{
         "href" => "https://cloud-api.yandex.net/v1/disk/operations/06c5855d7869bd5de5de81906acb97d4fa2bb2d8480564640be4c9bdccb5e48a",
         "method" => "GET",
         "templated" => false
       } }
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
    Move folder from one folder to another. Return error if destination folder already exists.
    Pass `overwrite: true` to overwrite existing files.
  ## Examples
      iex> YandexDisk.Folder.move(client, from: "disk:/test/test_folder4", to: "disk:/test/test_folder6")
      { :ok,
       %{
         "href" => "https://cloud-api.yandex.net/v1/disk/operations/6cbde5753ff3092032ae8a4e08e3226c6fb869fd6c80b08415fdb6063a09c105",
         "method" => "GET",
         "templated" => false
       } }

       iex> YandexDisk.Folder.move(client, from: "disk:/test/test_folder4", to: "disk:/test/test_folder6")
       { :error, "DiskNotFoundError", "Resource not found." }
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
    Delete folder
  ## Examples
      iex> YandexDisk.Folder.destroy(client, yandex_path: "disk:/test/test_folder4/test_folder14")
      { :ok, :ok }
  See: 
    * [Official docs](https://yandex.ru/dev/disk/api/reference/delete-docpage/)
  """
  @spec destroy(YandexDisk.client(), Keyword.t()) ::
          {:ok, YandexDisk.url()} | {:ok, :ok} | YandexDisk.error_result()
  def destroy(client, args) do
    {yandex_path, args} = Keyword.pop(args, :yandex_path)
    query = Keyword.merge(args, path: yandex_path)

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
end
