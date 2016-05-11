require 'rails_helper'

describe 'qiniu_audio_and_video_transcode' do
  before{
    module FilePartUpload
      class Util

        def self.put_to_qiniu_transcode_queue(origin_key, fops)
          return "#{origin_key}_#{fops}_fops"
        end

        def self.get_qiniu_transcode_status(persistance_id)
          return 0
        end

      end
    end


    FilePartUpload.config do
      mode :qiniu

      qiniu_bucket    "fushang318"
      qiniu_domain    "http://qiniu_domain"
      qiniu_base_path "f"
      qiniu_audio_and_video_transcode :enable
    end

    callback_body_video = {
        bucket: "fushang318",
        token: "f/aQK4F8rt.mp4",
        file_size: "912220",
        image_rgb: "",
        original: "腾讯网迷你版 2015_9_29 16_11_59.mp4",
        mime: "video/mp4",
        image_width: "",
        image_height: "",
        avinfo_format: "mov,mp4,m4a,3gp,3g2,mj2",
        avinfo_total_bit_rate: "1791016",
        avinfo_total_duration: "4.074646",
        avinfo_video_codec_name: "h264",
        avinfo_video_bit_rate: "1650102",
        avinfo_video_duration: "4.070733",
        avinfo_height: "552",
        avinfo_width: "768",
        avinfo_audio_codec_name: "aac",
        avinfo_audio_bit_rate: "131534",
        avinfo_audio_duration: "4.074667"
      }

    callback_body_audio = {
      bucket: "fushang318",
      token: "f/G8UB1myy.mp3",
      file_size: "18392",
      image_rgb: "",
      original: "car-engine-loop-493679_SOUNDDOGS__au.mp3",
      mime: "audio/mp3",
      image_width: "",
      image_height: "",
      avinfo_format: "mp3",
      avinfo_total_bit_rate: "34771",
      avinfo_total_duration: "4.231500",
      avinfo_video_codec_name: "",
      avinfo_video_bit_rate: "",
      avinfo_video_duration: "",
      avinfo_height: "",
      avinfo_width: "",
      avinfo_audio_codec_name: "mp3",
      avinfo_audio_bit_rate: "32000",
      avinfo_audio_duration: "4.231500"
    }


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

    @file_entity_video = FilePartUpload::FileEntity.from_qiniu_callback_body(callback_body_video)
    @file_entity_audio = FilePartUpload::FileEntity.from_qiniu_callback_body(callback_body_audio)
    @file_entity = FilePartUpload::FileEntity.from_qiniu_callback_body(callback_body)
  }

  it{
    expect(FilePartUpload.get_qiniu_audio_and_video_transcode).to eq("enable")
  }

  it{
    expect(@file_entity_video.valid?).to eq(true)

    expect(@file_entity_video.is_audio?).to eq(false)
    expect(@file_entity_video.is_video?).to eq(true)

    expect(@file_entity_video.transcode_info).to eq({"原画"=>"processing", "标清"=>"processing"})
    expect(@file_entity_video.transcode_success?).to eq(false)

    @file_entity_video.transcoding_records.each do |tr|
      tr.refresh_status_form_qiniu
    end

    expect(@file_entity_video.transcode_info).to eq({"原画"=>"success", "标清"=>"success"})
    expect(@file_entity_video.transcode_success?).to eq(true)
  }

  it{
    expect(@file_entity_audio.valid?).to eq(true)

    expect(@file_entity_audio.is_audio?).to eq(true)
    expect(@file_entity_audio.is_video?).to eq(false)

    expect(@file_entity_audio.transcode_info).to eq({"default"=>"processing"})
    expect(@file_entity_audio.transcode_success?).to eq(false)

    @file_entity_audio.transcoding_records.each do |tr|
      tr.refresh_status_form_qiniu
    end

    expect(@file_entity_audio.transcode_info).to eq({"default"=>"success"})
    expect(@file_entity_audio.transcode_success?).to eq(true)
  }

  it{
    expect(@file_entity.valid?).to eq(true)

    expect(@file_entity.is_audio?).to eq(false)
    expect(@file_entity.is_video?).to eq(false)
    expect(@file_entity.transcode_info).to eq({})

    expect(@file_entity.transcoding_records.count).to eq(0)
  }

end
