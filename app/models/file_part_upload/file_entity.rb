module FilePartUpload
  class FileEntity
    include Mongoid::Document
    include Mongoid::Timestamps
    extend Enumerize

    include FilePartUpload::QiniuValidate
    include FilePartUpload::QiniuCreateMethods
    include FilePartUpload::QiniuMethods

    # 原始文件名
    field :original, type: String
    # content_type
    field :mime,     type: String
    # image video office
    # field :kind,     type: String
    KINDS = [:image, :audio, :video, :application, :text, :office, :pdf]
    enumerize :kind, in: KINDS

    # 本地模式   时， 表示 保存的文件名
    # qiniu模式 时， 表示 文件在七牛 bucket 中保存的 token(path)
    field :token,    type: String

    # 保存文件的 meta 信息
    # 所有文件都会有 {"file_size" => 1000}
    # 具体特定文件的 meta 信息格式待确定
    field :meta,     type: Hash

    # 只用于 本地模式
    # 表示已经保存的文件片段的大小
    field :saved_size,  type: Integer

    # 只用于 本地模式
    # 表示是否已经把文件片段合并
    field :merged,      type: Boolean, default: false


    validates :original,    :presence => true
    validates :file_size,   :presence => true
    validates :mime,        :presence => true
    validates :kind,        :presence => true

    # 获取文件大小
    def file_size
      self.meta["file_size"]
    end

    def file_size=(file_size)
      self.meta = {} if self.meta.blank?
      self.meta["file_size"] = file_size.to_i
    end

    KINDS.each do |kind_sym|
      define_method "is_#{kind_sym}?" do
        self.kind.to_s == kind_sym.to_s
      end
    end

  end
end
