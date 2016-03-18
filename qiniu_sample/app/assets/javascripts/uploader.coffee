jQuery(document).on 'ready page:load', ->
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

    # 出现全局错误时（如文件大小超限制，文件类型不对），此方法会被调用
    @uploader_error: (up, err, err_tip)->
      console.log "uploader error"
      console.log up, err, err_tip

    # 所有上传队列项处理完毕时（成功或失败），此方法会被调用
    @alldone: ->
      console.log "alldone"

# -----------------------------------------------

  if jQuery('.btn-upload').length
    $browse_button = jQuery('.btn-upload')
    $dragdrop_area = jQuery(document.body)

    new QiniuFilePartUploader
      browse_button: $browse_button
      dragdrop_area: $dragdrop_area
      file_progress: QiniuFileProgress
      multi_selection: true
      enable_paste: true
      # 可以使用如下参数
      # max_file_size: "10mb"
      # mime_types : [{ title : "Image files", extensions : "jpg,gif,png" }]
