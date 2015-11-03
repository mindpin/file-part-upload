require 'rails_helper'

describe 'qiniu mode' do
  before{
    FilePartUpload.config do
      path '/f/:name'
      mode :qiniu

      qiniu_bucket    "fushang318"
      qiniu_domain    "http://qiniu_domain"
      qiniu_base_path "f"

      image_version :large do
        process :resize_to_fill => [180, 180]
      end
      image_version :normal do
        process :resize_to_fill => [64, 63]
      end
      image_version :small do
        process :resize_to_fill => [30, 32]
      end

      image_version :xxx do
        process :resize_to_fit => [30, 31]
      end
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
    image_versions = FilePartUpload.file_part_upload_config[:qiniu_image_versions]
    image_versions.should == {
      "large"  => {:type=>"resize_to_fill", :args=>[180, 180]},
      "normal" => {:type=>"resize_to_fill", :args=>[64, 63]},
      "small"  => {:type=>"resize_to_fill", :args=>[30, 32]},
      "xxx"    => {:type=>"resize_to_fit", :args=>[30, 31]}
    }
  }

  it{
    base_url = File.join(FilePartUpload.get_qiniu_domain, FilePartUpload.get_qiniu_base_path, 'IuR0fINf.jpg')
    expect(@file_entity.url(:large)).to eq("#{base_url}?imageMogr2/thumbnail/!180x180r/gravity/Center/crop/180x180")
    expect(@file_entity.url(:normal)).to eq("#{base_url}?imageMogr2/thumbnail/!64x63r/gravity/Center/crop/64x63")
    expect(@file_entity.url(:xxx)).to eq("#{base_url}?imageMogr2/thumbnail/30x31")
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
