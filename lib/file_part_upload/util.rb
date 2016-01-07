require 'mime/types'

module FilePartUpload
  class Util
    def self.mime_type(file_name)
      MIME::Types.type_for(file_name).first.content_type
    rescue
      'application/octet-stream'
    end

    def self.get_randstr_filename(filename)
      ext_name = File.extname(filename)
      return "#{randstr}#{ext_name.blank? ? "" : ext_name }".strip
    end

    def self.randstr(length=8)
      base = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      size = base.size
      re = '' << base[rand(size-10)]
      (length - 1).times {
        re << base[rand(size)]
      }
      re
    end

    def self.human_file_size(file_size)
      return "#{file_size} B" if file_size < 1024

      [
        [1024,      "B"],
        [1024 ** 2, "KB"],
        [1024 ** 3, "M"],
        [1024 ** 4, "G"],
        [1024 ** 5, "T"],
        [1024 ** 6, "P"],
        [1024 ** 7, "E"],
        [1024 ** 8, "Z"],
        [1024 ** 9, "Y"]
      ].each do |arg|
        if file_size < arg[0]
          return sprintf(sprintf("%.2f #{arg[1]}", file_size / (arg[0] / 1024 + 0.0)))
        end
      end

      file_size
    end
    
    def self.put_to_qiniu_transcode_queue(origin_key, fops)
      qiniu_bucket = FilePartUpload.get_qiniu_bucket
      notify_url   = FilePartUpload.get_qiniu_pfop_notify_url
      
      _, result = Qiniu::Fop::Persistance.pfop(
        bucket: qiniu_bucket,
        key: origin_key,
        fops: fops,
        "notifyURL" => notify_url
      )
      
      p "put_to_qiniu_transcode_queu"
      p _
      p result
      return result["persistentId"]
    end
    
    def self.splice_qiniu_saveas_fops_str(fops, transcode_key)
      qiniu_bucket = FilePartUpload.get_qiniu_bucket
      code = Qiniu::Utils.urlsafe_base64_encode("#{qiniu_bucket}:#{transcode_key}")
      "#{fops}|saveas/#{code}"
    end

    def self.get_qiniu_pdf_page_count(pdf_url)
      json_str = RestClient.get("#{pdf_url}?yifangyun_preview/v2/action=get_page_count").body
      JSON.parse(json_str)["page_count"].to_i
    end

    def self.get_qiniu_transcode_status(persistance_id)
      _, result = Qiniu::Fop::Persistance.prefop(persistance_id)
      return result["code"]
    end
    
    
    OFFICE_MIME_TYPE_LIST = [
      "text/csv", 
      "application/msword", 
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document", 
      "application/vnd.ms-powerpoint", 
      "application/vnd.openxmlformats-officedocument.presentationml.presentation", 
      "application/rtf", 
      "application/vnd.ms-excel", 
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    ]
    
    # TODO 编写测试
    def self.get_file_kind_by_mime_type(mime_type)
      kind  = mime_type.split("/").first
      return kind if ["image", "video", "audio"].include?(kind)
      
      return "office" if OFFICE_MIME_TYPE_LIST.include?(mime_type)
      return "pdf"    if mime_type == "application/pdf"
      
      return "application"
    end

  end
end
