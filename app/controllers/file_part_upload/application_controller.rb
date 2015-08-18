module FilePartUpload
  class ApplicationController < ActionController::Base
    layout "file_part_upload/application"

    if defined? PlayAuth
      helper PlayAuth::SessionsHelper
    end
  end
end