module FilePartUpload
  class TranscodingRecord
    include Mongoid::Document
    include Mongoid::Timestamps
    extend Enumerize

    field :name,                   type: String
    field :fops,                   type: String
    field :quniu_persistance_id,   type: String
    field :token

    enumerize :status, in: [:processing, :success, :failure], default: :processing

    belongs_to :file_entity

    before_create :send_to_qiniu_queue
    def send_to_qiniu_queue
      self.quniu_persistance_id = FilePartUpload::Util.put_to_qiniu_transcode_queue(
        self.file_entity.token,
        self.fops
      )
    end
    
    before_save :put_pdf_transcode_to_quene
    def put_pdf_transcode_to_quene
      return true if !self.file_entity.is_office? || self.name != "pdf" || !self.status.success?
      
      self.file_entity.update_page_count_by_pdf_url(self.url)
      self.file_entity.put_pdf_transcode_to_quene_by_page_count
    end

    before_save :record_image_size_by_token_on_transcode_success
    def record_image_size_by_token_on_transcode_success
      return true if (!self.file_entity.is_office? && !self.file_entity.is_pdf?) || self.name != "jpg" || !self.status.success?
      
      json_str = RestClient.get("#{self.url[0]}?imageInfo").body
      self.file_entity.meta["page_width"] = JSON.parse(json_str)["width"].to_i
      self.file_entity.meta["page_height"] = JSON.parse(json_str)["height"].to_i
      self.file_entity.save
    end

    def url
      File.join(FilePartUpload.get_qiniu_domain, [*token][0])
    end
    
    def urls
      [*token].map do |t|
        File.join(FilePartUpload.get_qiniu_domain, t)  
      end
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
