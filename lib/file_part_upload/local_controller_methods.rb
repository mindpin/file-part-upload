module FilePartUpload
  module LocalControllerMethods

    def self.included(base)
      base.skip_before_filter :verify_authenticity_token, :only => [:upload]
    end

    # params like:
    #   file_entity_id : 1 ( or nil )
    #        file_name : 'abc.zip'
    #        file_size : 345874
    #       start_byte : 1024
    #             blob : #### form_data ####

    def upload
      # plupload 组建不能修改文件片段参数名，只能是 file
      # 但是控制器按照 blob 参数处理的
      # 要把 blob 改为 file
      # 需要改 文档 测试 页面
      # TODO
      params[:blob] = params[:file]

      # 不允许上传零字节文件
      if params[:file_size] == 0 || (params[:blob] && params[:blob].size == 0)
        render :text => 'cannot upload a empty file.', :status => 415
        return
      end

      file_entity = _find_or_build_file_entity
      exist = _find_exist_file_entity(file_entity)

      file_entity = exist.blank? ? file_entity : exist
      file_entity.save

      # here
      if params[:start_byte].to_i == file_entity.saved_size
        file_entity.save_blob(params[:blob])
      end

      render :json => _build_json(file_entity)
    rescue FilePartUpload::AlreadyMergedError
      render :text => 'file already merged.', :status => 500
    rescue Exception => ex
      p ex
      puts ex.backtrace*"/n"
      render :text => 'params or other error.', :status => 500
    end


    private
      def _find_or_build_file_entity
        file_entity_id = params[:file_entity_id]
        return _build_file_entity if file_entity_id.blank?

        file_entity = FilePartUpload::FileEntity.where(:id => file_entity_id).first
        return _build_file_entity if file_entity.blank?

        return file_entity
      end

      def _build_file_entity
        return FilePartUpload::FileEntity.new({
          :original => params[:file_name],
          :file_size => params[:file_size]
        })
      end

      def _find_exist_file_entity(file_entity)
        return FilePartUpload::FileEntity.where(
          :original         => file_entity.original,
          :"meta.file_size" => file_entity.file_size
        ).first
      end

      def _build_json(file_entity)
        return {
          :file_entity_id  => file_entity.id.to_s,
          :file_entity_url => file_entity.url,
          :saved_size      => file_entity.saved_size
        }
      end


  end
end
