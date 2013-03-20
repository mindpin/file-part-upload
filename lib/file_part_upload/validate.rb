module FilePartUpload
  module Validate
    extend ActiveSupport::Concern

    included do |base|
      base.validates :attach_file_name,    :presence => true
      base.validates :attach_file_size,    :presence => true
      base.validates :attach_content_type, :presence => true
      base.validates :saved_size,          :presence => true

      base.before_validation :set_default_saved_size
      base.before_validation :set_content_type_by_file_name
    end

    def set_default_saved_size
      self.saved_size = 0 if self.saved_size.blank?
    end

    def set_content_type_by_file_name
      if self.attach_file_name.present?
        self.attach_content_type = Util.mime_type(self.attach_file_name)
      end
    end


  end
end