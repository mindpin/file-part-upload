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

    def self.put_to_qiniu_transcode_queue(qiniu_bucket, origin_key, transcode_key, fops)
      code = Qiniu::Utils.urlsafe_base64_encode("#{qiniu_bucket}:#{transcode_key}")

      _, result = Qiniu::Fop::Persistance.pfop(
        bucket: qiniu_bucket,
        key: origin_key,
        fops: "#{fops}|saveas/#{code}"
      )
      return result["persistentId"]
    end

    def self.get_qiniu_transcode_status(persistance_id)
      _, result = Qiniu::Fop::Persistance.prefop(persistance_id)
      return result["code"]
    end

  end
end
