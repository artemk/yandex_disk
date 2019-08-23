You should register your app to obtain ID and Password.

## Usage
Take a look at [hex docs](https://hexdocs.pm/yandex_disk/api-reference.html) for examples.

```
client = YandexDisk.Client.client(TOKEN)   
YandexDisk.Folder.destroy(client, yandex_path: "disk:/test", permanently: true)
```

## Features list

### Auth

- [x] Token
- [ ] Login/pass

### Disk

- [x] Info
- [x] Operation status

### File

- [x] Download
- [ ] Upload from url
- [x] Upload
- [x] Add metadata
- [x] Delete
- [x] Copy
- [x] Move
- [x] List latest files
- [x] List all files

### Folder
- [x] Create folder
- [x] Add metadata
- [x] Copy
- [x] Move
- [x] Delete

### Public file

- [x] Publish
- [x] Unpublish
- [x] List of published files
- [x] Move to Downloads
- [x] Download
- [x] Get meta


### Public folder

- [ ] Publish
- [ ] Unpublish
- [ ] List of published files
- [ ] Move to Downloads
- [ ] Download
- [ ] Add meta

### Trash

- [x] Clear
- [x] Restore
