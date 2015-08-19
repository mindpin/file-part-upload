require 'rails_helper'

describe 'related_path' do
  before{
    FilePartUpload.config do
      path 'xxx/:id/file/:name'
      url nil
      mode :local
    end
  }

  it{
    file_name = "text.doc"
    data_path = File.expand_path("../data",__FILE__)
    text_path = File.join(data_path, file_name)
    file = File.new(text_path)
    @entity = FilePartUpload::FileEntity.create(:original => file_name, :file_size => file.size)
    @entity.save_blob(file)
    File.exists?(@entity.path).should == true
    @entity.is_office?.should == true
  }

  it{
    file_name = "image.jpg"
    data_path = File.expand_path("../data",__FILE__)
    image_path = File.join(data_path, file_name)
    file = File.new(image_path)
    @entity = FilePartUpload::FileEntity.create(:original => file_name, :file_size => file.size)
    @entity.save_blob(file)
    File.exists?(@entity.path).should == true
    @entity.is_office?.should == false
  }

end
