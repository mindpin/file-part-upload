require 'rails_helper'

describe 'absolute_path' do
  before{
    FilePartUpload.config do
      path '/tmp/xxx/:id/file/:name'
      url nil
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
    expect(File.exists?(@entity.path)).to eq(true)
    dir = "/tmp/xxx/#{@entity.id}/file"
    expect(File.dirname(@entity.path)).to eq(dir)
    expect(File.basename(@entity.path)).not_to eq('image.jpg')
    expect(File.extname(@entity.path)).to eq('.jpg')
  }

  it{
    url_dir = "/tmp/xxx/#{@entity.id}/file"
    expect(File.dirname(@entity.url)).to eq(url_dir)
  }

end
