module FilePartUpload
  class Routing
    # FilePartUpload::Routing.mount "/file_part_upload", :as => 'file_part_upload'
    def self.mount(prefix, options)
      p "Deprecated 不再建议使用 FilePartUpload::Routing.mount 方法，建议换用 rails 原生 mount 方法"
      Rails.application.routes.draw do
        mount FilePartUpload::Engine => prefix, :as => options[:as]
      end
    end
  end
end
