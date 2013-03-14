module FilePartUpload
  class Util
    def self.mime_type(file_name)
      MIME::Types.type_for(file_name).first.content_type
    rescue
      'application/octet-stream'
    end
  end
end