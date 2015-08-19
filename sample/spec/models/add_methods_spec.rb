require 'rails_helper'

describe FilePartUpload do
  before{
    module ExpandMethods
      def ttt
        "ttt"
      end
    end
    FilePartUpload.config do
      add_methods ExpandMethods
    end

    file_name = "image.jpg"
    data_path = File.expand_path("../data",__FILE__)
    image_path = File.join(data_path, file_name)
    file = File.new(image_path)
    @entity = FilePartUpload::FileEntity.create(:original => file_name, :file_size => file.size)
  }

  it{
    expect(@entity.ttt).to eq("ttt")
  }
end
