require 'spec_helper'

module ExpandMethods
  def ttt
    "ttt"
  end
end
FilePartUpload.config do
  add_methods ExpandMethods
end

describe FilePartUpload do
  before{
    data_path = File.expand_path("../data",__FILE__)
    image_path = File.join(data_path, "image.jpg")
    file = File.new(image_path)
    @entity = FilePartUpload::FileEntity.create(:attach => file)
  }

  it{
    @entity.ttt.should == "ttt"
  }
end