module FilePartUpload
  module FileEntityActiveRecord
    extend ActiveSupport::Concern

    KINDS = [:image, :audio, :video, :application, :text, :office, :pdf]
    included do
      extend Enumerize

      include FilePartUpload::QiniuValidate
      include FilePartUpload::QiniuCreateMethods
      include FilePartUpload::QiniuMethods

      # image video office
      # field :kind,     type: String
      enumerize :kind, in: KINDS

      validates :original,    :presence => true
      validates :file_size,   :presence => true
      validates :mime,        :presence => true
      validates :kind,        :presence => true
    end

    class_methods do
    end

    # 获取文件大小
    def file_size
      meta_json["file_size"]
    end

    def file_size=(p_file_size)
      tmp = meta_json
      tmp["file_size"] = p_file_size.to_i
      self.meta = tmp.to_json
    end

    KINDS.each do |kind_sym|
      define_method "is_#{kind_sym}?" do
        self.kind.to_s == kind_sym.to_s
      end
    end

    def meta_json
      if meta.blank?
        {}
      else
        JSON.parse meta
      end
    end

  end
end
