# 待删除
# 待删除
# 待删除
# 待删除
# 待删除
module FilePartUpload
  class Attach
    def initialize(options)
      @instance = options[:instance]
      @name    = options[:name]
      @size    = options[:size]


      file_part_upload_config = FilePartUpload.file_part_upload_config


      @path_config = file_part_upload_config[:path] ||
        ":class/:id/attach/:name"

      url = file_part_upload_config[:url] || @path_config
      @url_config = File.join("/", url)
    end

    def path(version = nil)
      res = _convert_path(@path_config, version)
      return res if res[0] == "/"

      File.join(FilePartUpload.root, res)
    end

    def url(version = nil)
      res = _convert_path(@url_config, version)
      return res if res[0] == "/"

      File.join(FilePartUpload.base_path, res)
    end

    def content_type
      @instance.attach_content_type
    end

    def size
      File.size(path)
    end

    def resize!
      return if !content_type.match("image")
      FilePartUpload::MiniMagick.resize!(self)
    end

    private
    # "file_part_upload/:class/:id/attach/:name"
    # =>
    # "file_part_upload/file_entity/1/attach/xxx.jpg"
    def _convert_path(config_string, version = nil)
      # convert :class
      config_string = config_string.gsub(':class', @instance.class.name.tableize)

      # convert :id
      config_string = config_string.gsub(':id', @instance.id.to_s)

      # convert :name
      if version.blank?
        config_string = config_string.gsub(':name', @name)
      else
        config_string = config_string.gsub(':name', "#{version}_#{@name}" )
      end

      config_string
    end

  end
end
