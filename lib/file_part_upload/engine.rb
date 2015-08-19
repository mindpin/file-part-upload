module FilePartUpload
  class Engine < ::Rails::Engine
    initializer "file_part_upload.setup_paths" do
      FilePartUpload.root = Rails.root.join(Rails.public_path).to_s
      FilePartUpload.base_path = ENV['RAILS_RELATIVE_URL_ROOT'] || '/'
    end

    isolate_namespace FilePartUpload
    config.to_prepare do
      ApplicationController.helper ::ApplicationHelper
    end
  end
end
