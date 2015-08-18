require 'spec_helper'

FilePartUpload.config do
  path 'xxx/:id/file/:name'
end

describe 'related_path' do
  it{
    data_path = File.expand_path("../data",__FILE__)
    text_path = File.join(data_path, "text.doc")
    file = File.new(text_path)
    @entity = FilePartUpload::FileEntity.create(:attach => file)
    File.exists?(@entity.attach.path).should == true
    @entity.is_office?.should == true
  }

  it{
    data_path = File.expand_path("../data",__FILE__)
    image_path = File.join(data_path, "image.jpg")
    file = File.new(image_path)
    @entity = FilePartUpload::FileEntity.create(:attach => file)
    File.exists?(@entity.attach.path).should == true
    @entity.is_office?.should == false
  }

end