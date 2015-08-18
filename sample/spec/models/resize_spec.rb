require 'rails_helper'

describe 'resize' do
  describe 'check image_versions parse' do
    before{
      FilePartUpload.config do
        path '/tmp/xxx/:id/file/:name'

        image_version :large do
          process :resize_to_fill => [180, 180]
        end
        image_version :normal do
          process :resize_to_fill => [64, 64]
        end
        image_version :small do
          process :resize_to_fill => [30, 30]
        end

        image_version :xxx do
          process :resize_to_fit => [30, 31]
        end
      end
    }
    
    it{
      image_versions = FilePartUpload.file_part_upload_config[:image_versions]
      image_versions.should == [
        {:name=>"large", :type=>"resize_to_fill", :args=>[180, 180]},
        {:name=>"normal", :type=>"resize_to_fill", :args=>[64, 64]},
        {:name=>"small", :type=>"resize_to_fill", :args=>[30, 30]},
        {:name=>"xxx", :type=>"resize_to_fit", :args=>[30, 31]}
      ]
    }
  end

  describe "version" do
    before{
      data_path = File.expand_path("../data",__FILE__)
      image_path = File.join(data_path, "image.jpg")
      file = File.new(image_path)
      @entity = FilePartUpload::FileEntity.create(:attach => file)
    }

    it{
      name = @entity.attach.path.match(/file\/(.*)\.jpg/)[1]
      @entity.attach.path(:xxx).match(/file\/xxx_#{name}\.jpg/).class.should == MatchData
      @entity.attach.path(:normal).match(/file\/normal_#{name}\.jpg/).class.should == MatchData

      @entity.attach.url.match(/file\/#{name}\.jpg/).class.should == MatchData
      @entity.attach.url(:xxx).match(/file\/xxx_#{name}\.jpg/).class.should == MatchData
      @entity.attach.url(:normal).match(/file\/normal_#{name}\.jpg/).class.should == MatchData
    }

    it{
      data_path = File.expand_path("../data",__FILE__)
      image_path = File.join(data_path, "text.txt")
      file = File.new(image_path)
      @entity = FilePartUpload::FileEntity.create!(:attach => file)
    }
  end
end
