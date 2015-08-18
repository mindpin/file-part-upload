require 'rails_helper'

describe 'absolute_path' do
  before{
    FilePartUpload.config do
      path '/tmp/xxx/:id/file/:name'
    end

    data_path = File.expand_path("../data",__FILE__)
    image_path = File.join(data_path, "image.jpg")
    file = File.new(image_path)
    @entity = FilePartUpload::FileEntity.create(:attach => file)
  }

  it{
    File.exists?(@entity.attach.path).should == true
    dir = "/tmp/xxx/#{@entity.id}/file"
    File.dirname(@entity.attach.path).should == dir
    File.basename(@entity.attach.path).should_not == 'image.jpg'
    File.extname(@entity.attach.path).should == '.jpg'
  }

  it{
    url_dir = "/tmp/xxx/#{@entity.id}/file"
    File.dirname(@entity.attach.url).should == url_dir
  }

end
