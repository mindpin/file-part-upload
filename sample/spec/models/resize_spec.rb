require 'rails_helper'

describe 'resize' do
  describe 'check image_versions parse' do
    before{
      FilePartUpload.config do
        path '/tmp/xxx/:id/file/:name'
        url  nil
        mode :local

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
      file_name = "image.jpg"
      data_path = File.expand_path("../data",__FILE__)
      image_path = File.join(data_path, file_name)
      file = File.new(image_path)
      @entity = FilePartUpload::FileEntity.create(:original => file_name, :file_size => file.size)
      @entity.save_blob(file)
    }

    it{
      name = @entity.path.match(/file\/(.*)\.jpg/)[1]
      @entity.path(:xxx).match(/file\/xxx_#{name}\.jpg/).class.should == MatchData
      @entity.path(:normal).match(/file\/normal_#{name}\.jpg/).class.should == MatchData

      @entity.url.match(/file\/#{name}\.jpg/).class.should == MatchData
      @entity.url(:xxx).match(/file\/xxx_#{name}\.jpg/).class.should == MatchData
      @entity.url(:normal).match(/file\/normal_#{name}\.jpg/).class.should == MatchData
    }

    it '上传非图片类型的文件，不会对文件进行图片缩放操作' do
      file_name = "text.txt"
      data_path = File.expand_path("../data",__FILE__)
      image_path = File.join(data_path, file_name)
      file = File.new(image_path)
      @entity = FilePartUpload::FileEntity.create!(:original => file_name, :file_size => file.size)
      @entity.save_blob(file)
      File.exists?(@entity.path).should == true
      File.exists?(@entity.path(:xxx)).should == false
    end
  end
end
