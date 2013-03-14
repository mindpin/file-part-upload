module FilePartUpload
  class Attach
    def initialize(options)
      @instance = options[:instance]
      @name    = options[:name]
      @size    = options[:size]
    end

    def path
      File.join(FilePartUpload.root, _path)
    end

    def url
      File.join(FilePartUpload.base_path, _path)
    end

    def content_type
      @instance.attach_content_type
    end

    def size
      File.size(path)
    end

    private
    def _path
      File.join('file_part_upload', @instance.class.name, 
        @instance.id.to_s, 'attach', @name)
    end
  end
end