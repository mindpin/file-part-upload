module FilePartUpload
  module OfficeMethods
    def is_office?
      ext = File.extname(self.token).downcase
      office_exts = %w{.doc .docx .docm .dot .ppt .pptm .pptx .xls .xlsb .xlsm .xlsx}
      office_exts.include?(ext)
    end
  end
end
