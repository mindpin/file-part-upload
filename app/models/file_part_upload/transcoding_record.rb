module FilePartUpload
  if defined? ::ActiveRecord::Base
    class TranscodingRecord < ActiveRecord::Base
      include FilePartUpload::TranscodingRecordActiveRecord
    end
  end

  if defined? ::Mongoid::Document
    class TranscodingRecord
      include FilePartUpload::TranscodingRecordMongoid
    end
  end
end
