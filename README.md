[qiniu方式使用说明](README_QINIU.md)

[local方式使用说明](README_LOCAL.md)


#### 模型上的查询方法
```ruby
file_entity = FilePartUpload.last

# 文件 路径
file_entity.path

# 文件 url
file_entity.url(version = nil)

# 文件 大小
file_entity.file_size

# 文件 原始名
file_entity.original

# 文件 mime
file_entity.mime

# 文件 kind
file_entity.kind

# 文件 meta
file_entity.meta
```
