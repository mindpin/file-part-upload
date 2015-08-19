require 'rails_helper'

describe 'set_url' do
  before{
    FilePartUpload.config do
      url '/xxx/:id/file/:name'
      path nil
      mode :local
    end

    file_name = "image.jpg"
    data_path = File.expand_path("../data",__FILE__)
    image_path = File.join(data_path, file_name)
    file = File.new(image_path)
    @entity = FilePartUpload::FileEntity.create(:original => file_name, :file_size => file.size)
    @entity.save_blob(file)
  }

  it{
    File.exists?(@entity.path).should == true
    dir = File.join(FilePartUpload.root, "file_part_upload/file_entities/#{@entity.id}/attach")
    File.dirname(@entity.path).should == dir
  }

  it{
    url_dir = File.join("/xxx/#{@entity.id}/file")
    File.dirname(@entity.url).should == url_dir
  }

end
