require 'rails_helper'

describe 'related_path' do
  before{
    FilePartUpload.config do
      path 'xxx/:id/file/:name'
    end

    data_path = File.expand_path("../data",__FILE__)
    image_path = File.join(data_path, "image.jpg")
    file = File.new(image_path)
    @entity = FilePartUpload::FileEntity.create(:attach => file)
  }

  it{
    File.exists?(@entity.attach.path).should == true
    dir = File.join(FilePartUpload.root, "xxx/#{@entity.id}/file")
    File.dirname(@entity.attach.path).should == dir
  }

  it{
    url_dir = File.join("/xxx/#{@entity.id}/file")
    File.dirname(@entity.attach.url).should == url_dir
  }

end
