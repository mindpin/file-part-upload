module FilePartUpload
  if defined? ::ActiveRecord::Base
    class FileEntity < ActiveRecord::Base
      include FilePartUpload::FileEntityActiveRecord
    end
  end

  if defined? ::Mongoid::Document
    class FileEntity
      include FilePartUpload::FileEntityMongoid
    end
  end
end
