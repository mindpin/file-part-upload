module FilePartUpload
  class LocalPathUtil
    def self.convert_path(file_entity, config_string, version = nil)
      # convert :class
      config_string = config_string.gsub(':class', file_entity.class.name.tableize)

      # convert :id
      config_string = config_string.gsub(':id', file_entity.id.to_s)

      # convert :name
      if version.blank?
        config_string = config_string.gsub(':name', file_entity.token)
      else
        config_string = config_string.gsub(':name', "#{version}_#{file_entity.token}" )
      end

      config_string
    end
  end
end
