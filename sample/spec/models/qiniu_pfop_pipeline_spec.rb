require 'rails_helper'

describe 'get_qiniu_pfop_pipeline' do
    it{
      expect(FilePartUpload.get_qiniu_pfop_pipeline).to eq(nil)

      FilePartUpload.config do
        path '/f/:name'
        mode :qiniu

        qiniu_bucket    "fushang318"
        qiniu_domain    "http://qiniu_domain"
        qiniu_base_path "f"
        qiniu_audio_and_video_transcode :enable
        qiniu_pfop_pipeline "hahaha"
      end

      expect(FilePartUpload.get_qiniu_pfop_pipeline).to eq("hahaha")
    }

end
