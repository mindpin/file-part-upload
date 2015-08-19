require 'rails_helper'

describe 'related_path' do
  before{
    FilePartUpload.config do
      mode :local
      path nil
      url  nil
    end
  }

  it{
    entity = FilePartUpload::FileEntity.create(:original => '1.jpg', :file_size => 10)
    expect(entity.kind).to eq("image")
  }

end
