jQuery(document).on 'ready page:load', ->
  class LocalFileProgress
    constructor: (uploading_file, @uploader)->
      @file = uploading_file
      console.log @file

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
