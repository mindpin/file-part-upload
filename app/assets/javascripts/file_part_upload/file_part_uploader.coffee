# options
# browse_button: 上传按钮
# dragdrop_area: 接收文件拖拽的区域
# file_progress: 处理上传进度的回调类
# max_file_size: 允许上传的文件大小 比如 "10mb"
# mime_types : 允许上传的文件类型 比如 [{ title : "Image files", extensions : "jpg,gif,png" }]

class FilePartUploader
  constructor: (options)->
    @$browse_button = options["browse_button"]
    @$drag_area_ele = options["dragdrop_area"]
    @max_file_size  = options["max_file_size"] || "100mb"
    @mime_types     = options["mime_types"] || []
    @$file_progress = options["file_progress"] || FilePartUploaderFileProgress

    @dom_data = @$browse_button.data()
    console.log @dom_data

    # 上传进度显示对象
    @file_progresses = {}

    if "qiniu" == @dom_data["mode"]
      @_init_qiniu()

    if "local" == @dom_data["mode"]
      @_init_local()

  _init_local: ()->
    @local_upload_url = @dom_data['localUploadUrl']

    @local_upload = new plupload.Uploader
      runtimes: 'html5,flash,html4'
      browse_button: @$browse_button.get(0)
      url: @local_upload_url
      max_file_size: @max_file_size
      filters:
        mime_types: @mime_types
      max_retries: 1
      drop_element: @$drag_area_ele.get(0)
      chunk_size: '4mb'
      multipart: true
      multipart_params: {}

    @local_upload.init()

    @local_upload.bind "FilesAdded", (up, files)=>
      console.debug 'many files'
      plupload.each files, (file)=>
        file.offset = 0
        params = @local_upload.settings.multipart_params
        console.log file
        params.file_size = file.size
        params.file_name  = file.name
        params.start_byte = file.offset
        params.file_entity_id = null
        if not @file_progresses[file.id]?
          @file_progresses[file.id] = new @$file_progress(file, up)
      up.start()

    @local_upload.bind "ChunkUploaded", (up, file, response)=>
      console.log "ChunkUploaded"
      console.log response

      params = @local_upload.settings.multipart_params
      file.offset = response.offset
      params.start_byte = file.offset

      info = jQuery.parseJSON(response.response);
      params.file_entity_id = info.file_entity_id

    @local_upload.bind "BeforeUpload", (up, file)=>
      console.debug 'before upload'
      if not @file_progresses[file.id]?
        @file_progresses[file.id] = new @$file_progress(file, up)

        # 该方法第三个被触发，上传结束前持续被触发
    @local_upload.bind "UploadProgress", (up, file)=>
      console.debug 'upload progress'
      chunk_size = plupload.parseSize up.getOption('chunk_size')
      @file_progresses[file.id].update()
      # 当前进度 #{file.percent}%，
      # 速度 #{up.total.bytesPerSec}，

    # 该方法在上传成功结束时触发
    @local_upload.bind "FileUploaded", (up, file, info_json)=>
      console.debug 'file uploaded'
      info = jQuery.parseJSON(info_json.response);
      @file_progresses[file.id].success(info)

    # 该方法在上传出错时触发
    @local_upload.bind "Error", (up, err, errTip)=>
      fp = @file_progresses[err.file.id]
      if fp and fp.error
        console.warn("file progress 的 error 实例方法在将来的版本中将要被去除，请换用 error 类方法")
        fp.error(up, err, errTip)
      else
        @$file_progress.error(up, err, errTip)

    # 该方法在整个队列处理完毕后触发
    @local_upload.bind "UploadComplete", =>
      @$file_progress.alldone()

    # 注册图片粘贴事件
    new PasteImage (file)=>
      if file?
        file.name = "paste-#{(new Date).valueOf()}.png"
        @local_upload.addFile file


  _init_qiniu: ()->
    @qiniu_domain       = @dom_data['qiniuDomain']
    @qiniu_base_path    = @dom_data['qiniuBasePath']
    @qiniu_uptoken_url  = @dom_data['qiniuUptokenUrl']
    @qiniu_callback_url = @dom_data['qiniuCallbackUrl']

    @qiniu_all_complete_callback = =>
      all_complete = true

      for file_id, file_progress of @file_progresses
        if !file_progress.complete
          all_complete = false
          break

      if all_complete
        @$file_progress.alldone()
      else
        setTimeout @qiniu_all_complete_callback, 100



    @qiniu = Qiniu.uploader
      runtimes: 'html5,flash,html4'
      browse_button: @$browse_button.get(0)
      uptoken_url: @qiniu_uptoken_url
      domain: @qiniu_domain
      max_file_size: @max_file_size
      filters:
        mime_types: @mime_types
      max_retries: 1
      dragdrop: true
      drop_element: @$drag_area_ele.get(0)
      chunk_size: '4mb'
      auto_start: true
      x_vars:
        original: (up, file)->
          file.name
      init:
        ###
          文档参考：
          http://developer.qiniu.com/docs/v6/sdk/javascript-sdk.html
        ###

        # 指定七牛文件 key 的个性化生成规则
        # 该方法首先被触发
        Key: (up, file)=>
          ext = file.name.split(".").pop()
          ext = ext.toLowerCase()
          "#{@qiniu_base_path}/#{jQuery.randstr()}.#{ext}"

        # 该方法第二个被触发
        BeforeUpload: (up, file)=>
          console.debug 'before upload'
          if not @file_progresses[file.id]?
            @file_progresses[file.id] = new @$file_progress(file, up)

        # 该方法第三个被触发，上传结束前持续被触发
        UploadProgress: (up, file)=>
          console.debug 'upload progress'
          chunk_size = plupload.parseSize up.getOption('chunk_size')
          @file_progresses[file.id].update()
          # 当前进度 #{file.percent}%，
          # 速度 #{up.total.bytesPerSec}，

        # 该方法在上传成功结束时触发
        FileUploaded: (up, file, info_json)=>
          console.debug 'file uploaded'
          info = jQuery.parseJSON(info_json);
          jQuery.ajax
            type: 'POST'
            url:  @qiniu_callback_url
            data: info
            success: (res)=>
              @file_progresses[file.id].success(res)
            error: (xhr)=>
              @file_progresses[file.id].error()
            complete: =>
              @file_progresses[file.id].complete = true

        # 该方法在上传出错时触发
        Error: (up, err, errTip)=>
          fp = @file_progresses[err.file.id]
          if fp and fp.error
            console.warn("file progress 的 error 实例方法在将来的版本中将要被去除，请换用 error 类方法")
            fp.error(up, err, errTip)
          else
            @$file_progress.error(up, err, errTip)

        # 同时选择多个文件时才会触发
        FilesAdded: (up, files)=>
          console.debug 'many files'
          plupload.each files, (file)=>
            if not @file_progresses[file.id]?
              @file_progresses[file.id] = new @$file_progress(file, up)

        # 该方法在整个队列处理完毕后触发
        UploadComplete: =>
          @qiniu_all_complete_callback()

    # 注册图片粘贴事件
    new PasteImage (file)=>
      if file?
        file.name = "paste-#{(new Date).valueOf()}.png"
        @qiniu.addFile file

###
  用于显示上传进度的类
  里面规定了上传进度如何被显示的一些方法
###
class FilePartUploaderFileProgress
  constructor: (qiniu_uploading_file, @uploader)->
    @file = qiniu_uploading_file
    console.log @file

  # 上传进度进度更新时调用此方法
  update: ->
    console.log "update"
    console.log "#{@file.percent}%"

  # 上传成功时调用此方法
  success: (info)->
    console.log "success"
    console.log info

  # 上传出错时调用此方法
  error: ->
    console.log "error"

  @alldone: ->
    console.log "alldone"

window.FilePartUploader = FilePartUploader
