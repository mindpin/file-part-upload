module FilePartUpload
  class FileEntity
    include Mongoid::Document
    include Mongoid::Timestamps

    field :attach_file_name,    :type => String
    field :attach_content_type, :type => String
    field :attach_file_size,    :type => Integer
    field :saved_file_name,     :type => String
    field :saved_size,          :type => Integer
    field :merged,              :type => Boolean, :default => false

    include FilePartUpload::Validate
    include FilePartUpload::Instance
  end
end