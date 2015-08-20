### 本地硬盘 作为后台存储

#### 安装

Gemfile  
```ruby
gem 'file-part-upload',
  :github => "mindpin/file-part-upload",
  :tag    => "2.0.0-beta2"
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
  mode :local

  path "/FILE_ENTITY_DATA/files/:id/file/:name"
end
```


#### 使用

app/assets/javascripts/application.js  
```js
//= require file_part_upload/application
//= require uploader
```

app/assets/javascripts/uploader.coffee  
```coffee
jQuery(document).on 'ready page:load', ->

  # 请根据实际需求重写这个类
  class LocalFileProgress
    constructor: (uploading_file, @uploader)->
      @file = uploading_file
      console.log @file
      window.afile = @file

    # 上传进度进度更新时调用此方法
    update: ->
      console.log "local update"
      console.log "#{@file.percent}%"

    # 上传成功时调用此方法
    success: (info)->
      console.log "local success"
      console.log info

    # 上传出错时调用此方法
    error: ->
      console.log "local error"

    @alldone: ->
      console.log "local alldone"


  if jQuery('.btn-upload').length
    $browse_button = jQuery('.btn-upload')
    $dragdrop_area = jQuery(document.body)

    new FilePartUploader
      browse_button: $browse_button
      dragdrop_area: $dragdrop_area
      file_progress: LocalFileProgress
```

view  
```haml
  %a.btn-upload{href: 'javascript:;', data: FilePartUpload.get_dom_data} 上传文件
```
