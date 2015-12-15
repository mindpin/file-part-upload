class FileEntityCkPlayer
  constructor: (@$ele)->
    console.log 1
    @xml_url = @$ele.data("xmlUrl")
    @url     = ["#{@$ele.data("url")}->video/mp4"]

    @flashvars =
      f: @xml_url
      a: 33
      s: 2
      c: 0
      v: 100
      h: 1

    @params =
      bgcolor: '#FFF'
      allowFullScreen: true
      allowScriptAccess: 'always'
      wmode: 'transparent'

    @swf_url = '/assets/file_part_upload/ckplayer/ckplayer.swf'

    @init_ckplayer()

  init_ckplayer: ->
    console.log this
    CKobject.embed @swf_url, @$ele.attr('id'),
      "ckplayer_#{@$ele.attr('id')}", '100%', '100%', true, @flashvars, @url, @params

jQuery(document).on 'page:change', ->
  if jQuery(".page-file-entity .ckplayer").length != 0
    new FileEntityCkPlayer jQuery(".page-file-entity .ckplayer")
