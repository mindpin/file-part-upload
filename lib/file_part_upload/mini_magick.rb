require "mini_magick"

module FilePartUpload
  class MiniMagick
    def self.resize!(attach)
      image_versions = FilePartUpload.file_part_upload_config[:image_versions]
      return if image_versions.blank?
      image_versions.each do |image_version|
        mm = FilePartUpload::MiniMagick.new(attach, image_version[:name])
        mm.send(image_version[:type], *image_version[:args])
      end
    end

    def initialize(attach, version_name)
      @path = _init(attach, version_name)
    end

    def _init(attach, version_name)
      path = attach.path(version_name)
      File.open(attach.path) do |file|
        upload_file = FilePartUpload::UploadFile.new(file)
        upload_file.copy_to(path)
      end
      path
    end

    def current_path
      @path
    end

    def resize_to_fit(width, height)
      manipulate! do |img|
        img.resize "#{width}x#{height}"
        img = yield(img) if block_given?
        img
      end
    end

    def resize_to_fill(width, height, gravity = 'Center')
      manipulate! do |img|
        cols, rows = img[:dimensions]
        img.combine_options do |cmd|
          if width != cols || height != rows
            scale_x = width/cols.to_f
            scale_y = height/rows.to_f
            if scale_x >= scale_y
              cols = (scale_x * (cols + 0.5)).round
              rows = (scale_x * (rows + 0.5)).round
              cmd.resize "#{cols}"
            else
              cols = (scale_y * (cols + 0.5)).round
              rows = (scale_y * (rows + 0.5)).round
              cmd.resize "x#{rows}"
            end
          end
          cmd.gravity gravity
          cmd.background "rgba(255,255,255,0.0)"
          cmd.extent "#{width}x#{height}" if cols != width || rows != height
        end
        img = yield(img) if block_given?
        img
      end
    end

    def manipulate!
      image = ::MiniMagick::Image.open(current_path)

      begin
        # image.format(@format.to_s.downcase) if @format
        image = yield(image)
        image.write(current_path)
        image.run_command("identify", current_path)
      ensure
        image.destroy!
      end
    rescue ::MiniMagick::Error, ::MiniMagick::Invalid => e
      # default = I18n.translate(:"errors.messages.mini_magick_processing_error", :e => e, :locale => :en)
      # message = I18n.translate(:"errors.messages.mini_magick_processing_error", :e => e, :default => default)
      raise ::MiniMagick::Error, "::MiniMagick::Error"
    end
  end
end