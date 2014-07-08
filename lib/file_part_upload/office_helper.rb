module FilePartUpload
  module OfficeHelper
 
    def office_online_view_url(office_file_url_or_file_entity)
      case office_file_url_or_file_entity
      when String
        _office_online_view_url_by_url(office_file_url_or_file_entity)
      when FileEntity
        _office_online_view_url_by_file_entity(office_file_url_or_file_entity)
      end
    end

    private
      def _office_online_view_url_by_url(office_file_url)
        src = URI.escape(office_file_url, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
        "http://view.officeapps.live.com/op/view.aspx?src=#{src}"
      end
 
    def _office_online_view_url_by_file_entity(file_entity)
      url = File.join(request.host, file_entity.attach.url)
      _office_online_view_url_by_url(url)
    end
  end
end