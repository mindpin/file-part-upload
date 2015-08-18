require 'rails_helper'

describe 'set_url' do
  before{
    FilePartUpload.config do
      url '/xxx/:id/file/:name'
      path nil
    end

    data_path = File.expand_path("../data",__FILE__)
    image_path = File.join(data_path, "image.jpg")
    file = File.new(image_path)
    @entity = FilePartUpload::FileEntity.create(:attach => file)
  }

  it{
    File.exists?(@entity.attach.path).should == true
    dir = File.join(FilePartUpload.root, "file_part_upload/file_entities/#{@entity.id}/attach")
    File.dirname(@entity.attach.path).should == dir
  }

  it{
    url_dir = File.join("/xxx/#{@entity.id}/file")
    File.dirname(@entity.attach.url).should == url_dir
  }

end
