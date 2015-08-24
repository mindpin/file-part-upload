require 'rails_helper'

describe 'local mode meta' do
  before{
    FilePartUpload.config do
      path '/FILE_ENTITY_DATA/files/:id/file/:name'
      mode :local
    end

    @data_path = File.expand_path("../data",__FILE__)
    @image_path = File.join(@data_path, "image.jpg")

    file_name = File.basename(@image_path)
    @file_size = File.size(@image_path)
    @blob = File.new(@image_path)

    @file_entity = FilePartUpload::FileEntity.new(:original => file_name, :file_size => @file_size)
    @file_entity.save
    @file_entity.save_blob(@blob)
  }

  it{
    expect(@file_entity.uploaded?).to eq(true)
    expect(@file_entity.meta["image"]["width"]).to eq(1600)
    expect(@file_entity.meta["image"]["height"]).to eq(1200)
  }


end
