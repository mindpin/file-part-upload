# options
# -----------------------------
# browse_button:       上传按钮 jQuery 对象
# dragdrop_area:       接收文件拖拽的区域 jQuery 对象
# max_file_size:       允许上传的文件大小，默认 100MB
# mime_types:          允许上传的文件类型，默认 []，举例： [{ title : "Image files", extensions : "jpg,gif,png" }]
# enable_paste:        是否允许粘贴行为，默认否
# multi_selection:     是否允许选择多文件，默认否
# file_progress_class: 处理上传进度的回调类，由集成者自行实现
# -----------------------------

class @QiniuFilePartUploader
  constructor: (options)->
    @$browse_button       = options['browse_button']
    @$drag_area_ele       = options['dragdrop_area']
    @max_file_size        = options['max_file_size'] || '100mb'
    @mime_types           = options['mime_types'] || []
    @enable_paste         = !!options['enable_paste']
    @multi_selection      = !!options['multi_selection']
    @file_progress_class  = options["file_progress_class"] || FilePartUploaderFileProgress

    # 上传进度显示对象实例集合
    @file_progress_instances = {}

    @init()
    @init_paste_handle()

  init: ->
    dom_data = @$browse_button.data()
    console.debug 'browse button dom data:'
    console.debug dom_data
    @qiniu_domain       = dom_data['qiniuDomain']
    @qiniu_base_path    = dom_data['qiniuBasePath']
    @qiniu_uptoken_url  = dom_data['qiniuUptokenUrl']
    @qiniu_callback_url = dom_data['qiniuCallbackUrl']

    console.debug {
      'qiniu_domain':       @qiniu_domain
      'qiniu_base_path':    @qiniu_base_path
      'qiniu_uptoken_url':  @qiniu_uptoken_url
      'qiniu_callback_url': @qiniu_callback_url
    }

    if not (@qiniu_domain and @qiniu_base_path and @qiniu_uptoken_url and @qiniu_callback_url)
      console.warn "需要在上传按钮的 DOM 上声明这些参数： data-qiniu-domain, data-qiniu-base-path, data-qiniu-uptoken-url, data-callback-url"

    @qiniu = Qiniu.uploader
      runtimes:         'html5,flash,html4'
      uptoken_url:      @qiniu_uptoken_url
      domain:           @qiniu_domain
      max_file_size:    @max_file_size
      max_retries:      1
      chunk_size:       '4mb'
      auto_start:       true
      multi_selection:  @multi_selection

      browse_button:  @$browse_button?.get(0)
      drop_element:   @$drag_area_ele?.get(0)
      dragdrop:       true

      filters:
        mime_types: @mime_types
      x_vars:
        original: (up, file)->
          file.name
      init:
        # 文档参考：
        # http://developer.qiniu.com/docs/v6/sdk/javascript-sdk.html
        # 指定七牛文件 key 的个性化生成规则
        # 该方法首先被触发
        Key: (up, file)=>
          ext = file.name.split(".").pop()
          ext = ext.toLowerCase()
          "#{@qiniu_base_path}/#{jQuery.randstr()}.#{ext}"

        # 该方法第二个被触发
        BeforeUpload: (up, file)=>
          console.debug 'before upload'
          if not @file_progress_instances[file.id]?
            @file_progress_instances[file.id] = new @file_progress_class(file, up)

        # 该方法第三个被触发，上传结束前持续被触发
        UploadProgress: (up, file)=>
          console.debug 'upload progress'
          chunk_size = plupload.parseSize up.getOption('chunk_size')
          @file_progress_instances[file.id].update?()
          # 当前进度 #{file.percent}%，
          # 速度 #{up.total.bytesPerSec}，

        # 该方法在上传成功结束时触发
        FileUploaded: (up, file, info_json)=>
          console.debug 'file uploaded, create file entity'
          info = jQuery.parseJSON(info_json);
          jQuery.ajax
            type: 'POST'
            url:  @qiniu_callback_url
            data: info
            success: (res)=>
              @file_progress_instances[file.id].success?(res)
            error: (xhr)=>
              @file_progress_instances[file.id].file_entity_error?(xhr)
            complete: =>
              delete @file_progress_instances[file.id]
              if Object.keys(@file_progress_instances).length is 0
                @file_progress_class.alldone()

        # 该方法在上传出错时触发
        Error: (up, err, err_tip)=>
          fp = @file_progress_instances[err.file.id]
          if fp?
            fp.file_error?(up, err, err_tip)
          else
            @file_progress_class.uploader_error?(up, err, err_tip)

        # 添加文件时就会触发
        FilesAdded: (up, files)=>
          plupload.each files, (file)=>
            if not @file_progress_instances[file.id]?
              @file_progress_instances[file.id] = new @file_progress_class(file, up)

        # 该方法在整个队列处理完毕后触发
        # 目前这个钩子没什么用
        UploadComplete: =>
          # @qiniu_all_complete_callback()

  init_paste_handle: ->
    # 注册图片粘贴事件，建议只用于图片
    if @enable_paste
      new PasteImage (file)=>
        if file?
          file.name = "paste-#{(new Date).valueOf()}.png"
          @qiniu.addFile file

# 用于显示上传进度的类
# 里面规定了上传进度如何被显示的一些方法
class FilePartUploaderFileProgress
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