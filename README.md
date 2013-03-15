file-part-upload
================

## 安装

```ruby
# Gemfile
gem 'file-part-upload', 
  :git => 'git://github.com/mindpin/file-part-upload.git',
  :tag => '0.0.1'
```

## 生成 gemeration

待完成


## 使用说明

### 给模型增加配置
```ruby
class FileEntity < ActiveRecord::Base
  file_part_upload
end
```

### 分段上传一个文件

```ruby
  # 第一步
  file_entity = FileEntity.new(:attach_file_name => file_name, :attach_file_size => @file_size)
  file_entity.save
  
  # 后续步骤
  # blob 是 file 对象
  blobs.each do |blob|
    file_entity.save_blob(blob)
  end
  
  
  # 是否上传完毕
  file_entity.uploaded?
  
  # 是否还没有上传完毕
  file_entity.uploading?
  
  # 文件路径
  file_entity.attach.path
  
  # 文件url
  file_entity.attach.url
  
  # 文件大小
  file_entity.attach.size
  
  # 文件 content_type
  file_entity.attach.content_type
```

### 整个文件上传

```ruby
  file_entity = FileEntity.new(:attach => file)
  file_entity.save
```


