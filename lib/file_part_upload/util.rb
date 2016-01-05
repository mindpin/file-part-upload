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

    def self.put_to_qiniu_transcode_queue(qiniu_bucket, origin_key, transcode_key, fops)
      code       = Qiniu::Utils.urlsafe_base64_encode("#{qiniu_bucket}:#{transcode_key}")
      notify_url = "http://develop-fushang318.c9users.io/file_part_upload/file_entities/pfop"
      RestClient.log = $stdout
      _, result = Qiniu::Fop::Persistance.pfop(
        bucket: qiniu_bucket,
        key: origin_key,
        fops: "#{fops}|saveas/#{code}",
        "notifyURL" => notify_url
      )
      p "put_to_qiniu_transcode_queue 111"
      p _
      p result
      return "1"
    end

    def self.get_qiniu_transcode_status(persistance_id)
      _, result = Qiniu::Fop::Persistance.prefop(persistance_id)
      return result["code"]
    end

  end
end
