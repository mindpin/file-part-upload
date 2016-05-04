module FilePartUpload
  class Engine < ::Rails::Engine
    initializer "file_part_upload.setup_paths" do |app|
      app.config.assets.precompile += %w( file_part_upload/uploader.js file_part_upload/ckplayer/*)
    end

    isolate_namespace FilePartUpload
    config.to_prepare do
      ApplicationController.helper ::ApplicationHelper
    end
  end
end
