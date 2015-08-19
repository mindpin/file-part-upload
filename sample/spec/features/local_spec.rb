require 'rails_helper'

describe 'local http api', :type => :feature do
  before{
    FilePartUpload.config do
      url nil
      path nil
      mode :local
    end

    @data_path = File.expand_path("../../models/data",__FILE__)
    @image_path = File.join(@data_path, "image.jpg")
    @file_name = File.basename(@image_path)
    @file_size = File.size(@image_path)
    @blob_1 = File.new(File.join(@data_path,'2/image_split_aa'))
    @blob_2 = File.new(File.join(@data_path,'2/image_split_ab'))

  }

  it {


    # params = {
    #   :file_name  => @file_name,
    #   :file_size  => @file_size,
    #   :start_byte => 0,
    #   :blob       => @blob_1
    # }
    # page.driver.post("/file_part_upload/file_entities/upload", :params => params, :multipart => true)

    expect {

        visit "/file_part_upload/file_entities/new"
        within(".new") do
          fill_in 'file_name', :with => @file_name
          fill_in 'file_size', :with => @file_size
          fill_in 'start_byte', :with => 0
          attach_file 'blob', @blob_1.path
        end
        click_button 'submit'
        json = JSON.parse(page.text)

        file_entity_id = json["file_entity_id"]
        saved_size     = json["saved_size"]

        visit "/file_part_upload/file_entities/new"
        within(".new") do
          fill_in 'file_name',      :with => @file_name
          fill_in 'file_size',      :with => @file_size
          fill_in 'start_byte',     :with => saved_size
          fill_in 'file_entity_id', :with => file_entity_id
          attach_file 'blob', @blob_2.path
        end
        click_button 'submit'


        entity = FilePartUpload::FileEntity.find(file_entity_id)
        expect(File.exists?(entity.path)).to eq(true)

        expect(File.size(entity.path)).to eq(@file_size)
    }.to change {FilePartUpload::FileEntity.count}.by(1)

  }
end
