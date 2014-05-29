module FilePartUpload
  module ControllerHelper
    def start_uploading(file_name, file_size)
      file_entity = FilePartUpload::FileEntity.new(:attach_file_name => file_name, :attach_file_size => file_size)
      file_entity.save
      file_entity
    end

    def continue_uploading(id, blob)
      file_entity = FilePartUpload::FileEntity.find(id)
      file_entity.save_blob(blob)
      file_entity
    end

    def full_upload(file)
      file_entity = FilePartUpload::FileEntity.new(:attach => file)
      file_entity.save
      file_entity
    end
  end
end