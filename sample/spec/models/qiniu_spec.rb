require 'rails_helper'

describe 'qiniu mode' do
  before{
    FilePartUpload.config do
      path '/f/:name'
      mode :qiniu

      qiniu_bucket    "fushang318"
      qiniu_domain    "http://qiniu_domain"
      qiniu_base_path "f"
    end

    callback_body = {
      bucket: "fushang318",
      token: "/f/IuR0fINf.jpg",
      file_size: "25067",
      original: "1-120GQF34TY.jpg",
      mime: "image/jpeg",
      image_width: "200",
      image_height: "200",
      image_rgb: "0x4f4951"
    }

    @file_entity = FilePartUpload::FileEntity.from_qiniu_callback_body(callback_body)
  }

  it{
    expect(@file_entity.original).to eq("1-120GQF34TY.jpg")
    expect(@file_entity.url).to eq(File.join(FilePartUpload.get_qiniu_domain, FilePartUpload.get_qiniu_base_path, 'IuR0fINf.jpg'))
    expect(@file_entity.kind.image?).to eq(true)
  }

  it{
    file_entity = FilePartUpload::FileEntity.find(@file_entity.id)
    expect(file_entity.file_size).to eq(25067)
  }


end
