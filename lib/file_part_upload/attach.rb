module FilePartUpload
  class Attach
    def initialize(options)
      @instance = options[:instance]
      @name    = options[:name]
      @size    = options[:size]


      file_part_upload_config = @instance.class.file_part_upload_config 


      @path_config = file_part_upload_config[:path] ||
        "file_part_upload/:class/:id/attach/:name"

      url = file_part_upload_config[:url] || @path_config
      @url_config = File.join("/", url)
    end

    def path
      res = _convert_path(@path_config)
      return res if res[0] == "/"

      File.join(FilePartUpload.root, res)
    end

    def url
      res = _convert_path(@url_config)
      return res if res[0] == "/"

      File.join(FilePartUpload.base_path, res)
    end

    def content_type
      @instance.attach_content_type
    end

    def size
      File.size(path)
    end

    private
    def _default_path
      File.join('file_part_upload', @instance.class.name.tableize, 
        @instance.id.to_s, 'attach', @name)
    end

    # "file_part_upload/:class/:id/attach/:name" 
    # =>
    # "file_part_upload/file_entity/1/attach/xxx.jpg"
    def _convert_path(config_string)
      # convert :class
      config_string = config_string.gsub(':class', @instance.class.name.tableize)

      # convert :id
      config_string = config_string.gsub(':id', @instance.id.to_s)

      # convert :name
      config_string = config_string.gsub(':name', @name)

      config_string      
    end

  end
end