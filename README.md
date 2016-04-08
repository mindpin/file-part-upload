# 用 qiniu 作为后台存储的使用说明

## 引入 gem
在 `Gemfile` 引入:
```ruby
gem 'file-part-upload',
  :github => "mindpin/file-part-upload",
  :tag    => "3.0.0"
```

## 基础配置
在 `config/initializers/file_part_upload.rb` 引入:
```ruby
FilePartUpload.config do
  mode :qiniu

  # 配置 qiniu 使用的 bucket 名称
  qiniu_bucket         "xxx"

  # 配置 qiniu 使用的 bucket 的 domain
  qiniu_domain         "http://xxx.xx.xx"

  # 配置要使用 bucket 的 子路径
  # 比如 base_path 如果是 "f",那么文件会上传到 bucket 下的 f 子路径下
  qiniu_base_path      "f"

  # 配置 qiniu 账号的 app access key
  qiniu_app_access_key "xxx"

  # 配置 qiniu 账号的 app secret key
  qiniu_app_secret_key "xxx"

  # 配置 qiniu callback host
  # 文件上传完毕后，如果需要转码，提交转码请求给七牛后，当转码完毕后，七牛会发送请求给 App-Server
  # 所以这里需要配置 App-Server Host,并且可以被公网访问
  qiniu_callback_host  "http://yy.yy.yy"

end
```

## 实现文件上传
在 `config/routes.rb` 引入:
```ruby
Rails.application.routes.draw do
  mount FilePartUpload::Engine => '/file_part_upload', :as => 'file_part_upload'
end
```

在 `app/assets/javascripts/application.js` 引入:
```ruby
//= require file_part_upload/uploader # 这个是 gem 自带的
//= require custom_uploader # 这个是你自己写的，写法看下面
```

编写 `app/assets/javascripts/custom_uploader.coffee` 文件，内容如下:
```coffee
jQuery(document).on 'ready page:load', ->
  # 请根据实际需求重写这个类
  class QiniuFileProgress
    constructor: (qiniu_uploading_file, @uploader)->
      @file = qiniu_uploading_file
      console.log @file

    # 某个文件上传进度更新时，此方法会被调用
    update: ->
      console.log "update"
      console.log "#{@file.percent}%"

    # 某个文件上传成功时，此方法会被调用
    success: (info)->
      console.log "success"
      console.log info

    # 某个文件上传出错时，此方法会被调用
    file_error: (up, err, err_tip)->
      console.log "file error"
      console.log up, err, err_tip

    # file entity 创建失败时，此方法会被调用
    file_entity_error: (xhr)->
      console.log "file entity error"
      console.log xhr.responseText

    # 出现全局错误时（如文件大小超限制，文件类型不对），此方法会被调用
    @uploader_error: (up, err, err_tip)->
      console.log "uploader error"
      console.log up, err, err_tip

    # 所有上传队列项处理完毕时（成功或失败），此方法会被调用
    @alldone: ->
      console.log "alldone"
```

然后，任何时候当你需要声明一个上传按钮时：

```coffee
if jQuery('.btn-upload').length
  $browse_button = jQuery('.btn-upload')
  $dragdrop_area = jQuery(document.body)

  new QiniuFilePartUploader
    browse_button: $browse_button
    dragdrop_area: $dragdrop_area
    file_progress: QiniuFileProgress
    max_file_size: "10mb" # 允许上传的文件大小，如果不传递该参数，默认是 "10mb"
    mime_types : [{ title : "Image files", extensions : "jpg,gif,png" }] # 限制允许上传的文件类型
```

haml 文件增加如下内容:
```ruby
%a.btn-upload{href: 'javascript:;', data: FilePartUpload.get_dom_data} 上传文件
```


## 模型上的查询方法
```ruby
file_entity = FilePartUpload::FileEntity.last

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

## 多种图片尺寸
在 `config/initializers/file_part_upload.rb` 引入:
```ruby
FilePartUpload.config do
  image_version :large do
    process :resize_to_fill => [180, 180]
  end
  image_version :normal do
    process :resize_to_fill => [64, 63]
  end
  image_version :small do
    process :resize_to_fill => [30, 32]
  end

  image_version :xxx do
    process :resize_to_fit => [30, 31]
  end
end
```

通过以下方式获取不同尺寸图片的 url  
```ruby
file_entity = FilePartUpload::FileEntity.last
file_entity.url(:large)
```

## 音视频转码
在 `config/initializers/file_part_upload.rb` 引入:
```ruby
FilePartUpload.config do
  # 是否开启转码
  qiniu_audio_and_video_transcode :enable

  # 设置转码队列名称（一般生产环境才需要设置）
  qiniu_pfop_pipeline "hahaha"
end
```

通过以下方式获取相关信息
```ruby
file_entity = FilePartUpload::FileEntity.last
# 转码后的文件 url
file_entity.transcode_url(transcoding_record_name = "default")
# 是否转码成功
file_entity.transcode_success?

#{
#  "default" => "success",
#  "transcoding_record_name1" => "success"
#}
file_entity.transcode_info


if file_entity.is_office?
  file_entity.transcode_url("pdf")
  file_entity.transcode_urls("jpg")
end

if file_entity.is_pdf?
  file_entity.transcode_urls("jpg")
end

file_entity.transcoding_records.each do |transcoding_record|
  transcoding_record.name
  transcoding_record.url
end
```

## 查看文件详情页面
访问 `http://<host>/<file_part_upload_engine_prefix>/file_entities/:id`
