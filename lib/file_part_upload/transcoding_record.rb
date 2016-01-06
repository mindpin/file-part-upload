module FilePartUpload
  class TranscodingRecord
    include Mongoid::Document
    include Mongoid::Timestamps
    extend Enumerize

    field :name,                   type: String
    field :fops,                   type: String
    field :quniu_persistance_id,   type: String
    field :token,                  type: String

    enumerize :status, in: [:processing, :success, :failure], default: :processing

    belongs_to :file_entity

    before_create :send_to_qiniu_queue
    def send_to_qiniu_queue
      self.quniu_persistance_id = FilePartUpload::Util.put_to_qiniu_transcode_queue(
        FilePartUpload.get_qiniu_bucket,
        self.file_entity.token,
        self.token,
        self.fops
      )
    end

    def url
      File.join(FilePartUpload.get_qiniu_domain, token)
    end

    def get_status
      if self.status.processing?
        refresh_status_form_qiniu
      end
      self.status
    end

    def refresh_status_form_qiniu
      code = FilePartUpload::Util.get_qiniu_transcode_status(self.quniu_persistance_id)
      update_status_by_code(code)
    end
    
    def update_status_by_code(code)
      case code
      when 0
        self.status = :success
      when 1,2
        self.status = :processing
      when 3,4
        self.status = :failure
      end

      if self.changed.include?("status")
        self.save
      end      
    end



  end
end
