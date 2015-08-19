require 'rails_helper'

describe 'local http api', :type => :feature do
  before{
    FilePartUpload.config do
      mode :qiniu

      qiniu_bucket    "fushang318"
      qiniu_domain    "http://qiniu_domain"
      qiniu_base_path "f"
      qiniu_app_access_key "access_key"
      qiniu_app_secret_key "secret_key"
    end
  }

  it {

    visit "/file_part_upload/file_entities/uptoken"
    json = JSON.parse(page.text)
    expect(json["uptoken"].blank?).to eq(false)


    @params = { "bucket"=>"fushang318",
      "token"=>"/f/yscPYbwk.jpeg",
      "file_size"=>"3514",
      "image_rgb"=>"0xee4f60",
      "original"=>"icon200x200.jpeg",
      "mime" => "image/png",
      "image_width"=>"200",
      "image_height"=>"200",
      "avinfo_format" => "",
      "avinfo_total_bit_rate" => "",
      "avinfo_total_duration" => "",
      "avinfo_video_codec_name" => "",
      "avinfo_video_bit_rate"   => "",
      "avinfo_video_duration"   => "",
      "avinfo_height"           => "",
      "avinfo_width"            => "",
      "avinfo_audio_codec_name" => "",
      "avinfo_audio_bit_rate"   => "",
      "avinfo_audio_duration"   => ""
    }

    expect {
      res = page.driver.post "/file_part_upload/file_entities", @params
      json = JSON.parse(res.body)

      entity = FilePartUpload::FileEntity.find(json["file_entity_id"])

      expect(entity.url).to       eq("http://qiniu_domain/f/yscPYbwk.jpeg")
      expect(entity.path).to      eq("/f/yscPYbwk.jpeg")
      expect(entity.file_size).to eq(3514)
      expect(entity.original).to  eq("icon200x200.jpeg")
      expect(entity.mime).to      eq("image/png")
      expect(entity.kind).to      eq("image")
      expect(entity.token).to     eq("/f/yscPYbwk.jpeg")

    }.to change {FilePartUpload::FileEntity.count}.by(1)

  }
end
