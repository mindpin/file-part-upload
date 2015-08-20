module FilePartUpload
  class Routing
    # FilePartUpload::Routing.mount "/file_part_upload", :as => 'file_part_upload'
    def self.mount(prefix, options)
      FilePartUpload.set_mount_prefix prefix

      Rails.application.routes.draw do
        mount FilePartUpload::Engine => prefix, :as => options[:as]
      end
    end
  end
end
