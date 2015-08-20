# qiniu
# 需要的 data
# qiniu_domain qiniu_base_path qiniu_uptoken_url

# local

class Uploader
  constructor: (@$browse_button, @$drag_area_ele)->
    data         = @$browse_button.data()
    console.log data

    if "qiniu" == data["mode"]
      @_init_qiniu()

    if "local" == data["mode"]
      @_init_local()

  _init_local: ()->
    data         = @$browse_button.data()
    console.log data
    @local_upload_url = data['localUploadUrl']

    # 上传进度显示对象
    @file_progresses = {}

    @local_upload = new plupload.Uploader
      runtimes: 'html5,flash,html4'
      browse_button: @$browse_button.get(0)
      url: @local_upload_url
      max_file_size: '100mb'
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
          @file_progresses[file.id] = new FileProgress(file, up)
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
        @file_progresses[file.id] = new FileProgress(file, up)

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
      @file_progresses[err.file.id].error()

    # 该方法在整个队列处理完毕后触发
    @local_upload.bind "UploadComplete", ->
      FileProgress.alldone()

    # 注册图片粘贴事件
    new PasteImage (file)=>
      if file?
        file.name = "paste-#{(new Date).valueOf()}.png"
        @local_upload.addFile file


  _init_qiniu: ()->
    data         = @$browse_button.data()
    console.log data
    @qiniu_domain      = data['qiniuDomain']
    @qiniu_base_path   = data['qiniuBasePath']
    @qiniu_uptoken_url = data['qiniuUptokenUrl']

    # 上传进度显示对象
    @file_progresses = {}

    @qiniu = Qiniu.uploader
      runtimes: 'html5,flash,html4'
      browse_button: @$browse_button.get(0),
      uptoken_url: @qiniu_uptoken_url,
      domain: @qiniu_domain,
      max_file_size: '100mb',
      max_retries: 1,
      dragdrop: true,
      drop_element: @$drag_area_ele.get(0),
      chunk_size: '4mb',
      auto_start: true,
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
          "/#{@qiniu_base_path}/#{jQuery.randstr()}.#{ext}"

        # 该方法第二个被触发
        BeforeUpload: (up, file)=>
          console.debug 'before upload'
          if not @file_progresses[file.id]?
            @file_progresses[file.id] = new FileProgress(file, up)

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
          @file_progresses[file.id].success(info)

        # 该方法在上传出错时触发
        Error: (up, err, errTip)=>
          @file_progresses[err.file.id].error()

        # 同时选择多个文件时才会触发
        FilesAdded: (up, files)=>
          console.debug 'many files'
          plupload.each files, (file)=>
            if not @file_progresses[file.id]?
              @file_progresses[file.id] = new FileProgress(file, up)

        # 该方法在整个队列处理完毕后触发
        UploadComplete: ->
          FileProgress.alldone()

    # 注册图片粘贴事件
    new PasteImage (file)=>
      if file?
        file.name = "paste-#{(new Date).valueOf()}.png"
        @qiniu.addFile file

###
  用于显示上传进度的类
  里面规定了上传进度如何被显示的一些方法
###
class FileProgress
  constructor: (qiniu_uploading_file, @uploader)->
    @file = qiniu_uploading_file
    console.log @file
    window.afile = @file

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


jQuery(document).on 'ready page:load', ->
  if jQuery('.btn-upload').length
    $browse_button = jQuery('.btn-upload')
    $dragdrop_area = jQuery(document.body)
    new Uploader($browse_button, $dragdrop_area)
