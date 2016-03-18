jQuery(document).on 'ready page:load', ->
  class QiniuFileProgress
    constructor: (uploading_file, @uploader)->
      @file = uploading_file
      console.log @file

    # 上传进度进度更新时调用此方法
    update: ->
      console.log "qiniu update"
      console.log "#{@file.percent}%"

    # 上传成功时调用此方法
    success: (info)->
      console.log "qiniu success"
      console.log info

    @alldone: ->
      console.log "qiniu alldone"

    @error: (up, err, errTip)->
      console.log "qiniu error"

  if jQuery('.btn-upload').length
    $browse_button = jQuery('.btn-upload')
    $dragdrop_area = jQuery(document.body)

    new FilePartUploader
      browse_button: $browse_button
      dragdrop_area: $dragdrop_area
      file_progress: QiniuFileProgress
      # 可以使用如下参数
      # max_file_size: "10mb"
      # mime_types : [{ title : "Image files", extensions : "jpg,gif,png" }]
