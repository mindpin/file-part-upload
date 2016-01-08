FilePartUpload.config do
  mode :qiniu

  qiniu_bucket         ENV["QINIU_BUCKET"]
  qiniu_domain         ENV["QINIU_DOMAIN"]
  qiniu_base_path      ENV["QINIU_BASE_PATH"]
  qiniu_app_access_key ENV["QINIU_APP_ACCESS_KEY"]
  qiniu_app_secret_key ENV["QINIU_APP_SECRET_KEY"]
  qiniu_callback_host  ENV["QINIU_CALLBACK_HOST"]
  
  qiniu_audio_and_video_transcode :enable
end
