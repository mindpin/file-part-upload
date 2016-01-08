### qiniu 作为后台存储

#### 安装

Gemfile  
```ruby
gem 'file-part-upload',
  :github => "mindpin/file-part-upload",
  :tag    => "2.2.0"
```

config/routes.rb  

**一定要注意必须遵循如下写法**
```ruby
Rails.application.routes.draw do

  # 在配置中增加如下这一行
  # 请不要用 rails 自带的 mount
  # 而是用 FilePartUpload::Routing.mount 方法
  FilePartUpload::Routing.mount "/file_part_upload", :as => 'file_part_upload'

end
```

config/initializers/file_part_upload.rb  
```ruby
FilePartUpload.config do
  mode :qiniu

  qiniu_bucket         "xxx"
  qiniu_domain         "http://xxx.xx.xx"
  qiniu_base_path      "f"
  qiniu_app_access_key "xxx"
  qiniu_app_secret_key "xxx"
  qiniu_callback_host  "http://yy.yy.yy"

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


#### 使用

app/assets/javascripts/application.js  
```js
//= require file_part_upload/uploader
//= require uploader
```

app/assets/javascripts/uploader.coffee  
```coffee
jQuery(document).on 'ready page:load', ->

  # 请根据实际需求重写这个类
  class QiniuFileProgress
    constructor: (uploading_file, @uploader)->
      @file = uploading_file
      console.log @file
      window.afile = @file

    # 上传进度进度更新时调用此方法
    update: ->
      console.log "qiniu update"
      console.log "#{@file.percent}%"

    # 上传成功时调用此方法
    success: (info)->
      console.log "qiniu success"
      console.log info

    # 上传出错时调用此方法
    error: ->
      console.log "qiniu error"

    @alldone: ->
      console.log "qiniu alldone"


  if jQuery('.btn-upload').length
    $browse_button = jQuery('.btn-upload')
    $dragdrop_area = jQuery(document.body)

    new FilePartUploader
      browse_button: $browse_button
      dragdrop_area: $dragdrop_area
      file_progress: QiniuFileProgress
```

view  
```haml
  %a.btn-upload{href: 'javascript:;', data: FilePartUpload.get_dom_data} 上传文件
```
