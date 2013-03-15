module FilePartUpload
  class Util
    def self.mime_type(file_name)
      MIME::Types.type_for(file_name).first.content_type
    rescue
      'application/octet-stream'
    end

    def self.get_randstr_filename(filename)
      ext_name = File.extname(filename)
      return "#{randstr}#{ext_name.blank? ? "" : ext_name }".strip
    end

    def self.randstr(length=8)
      base = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      size = base.size
      re = '' << base[rand(size-10)]
      (length - 1).times {
        re << base[rand(size)]
      }
      re
    end

  end
end