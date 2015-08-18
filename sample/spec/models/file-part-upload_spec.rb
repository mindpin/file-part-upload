require 'rails_helper'

describe FilePartUpload do
  before{
    FilePartUpload.config do
      url nil
      path nil
      mode :local
    end

    @data_path = File.expand_path("../data",__FILE__)
    @image_path = File.join(@data_path, "image.jpg")
  }

  describe '字段校验' do
    before{
      @file_name = File.basename(@image_path)
      @file_size = File.size(@image_path)
      @blob = File.new(File.join(@data_path,'1/image'))
    }

    it{
      expect{
        FilePartUpload::FileEntity.create!(:file_size => @file_size)
      }.to raise_error(Mongoid::Errors::Validations)
    }

    it{
      expect{
        FilePartUpload::FileEntity.create!(:file_size => @file_name)
      }.to raise_error(Mongoid::Errors::Validations)
    }

  end

  describe '异常处理' do
    before(:each){
      file_name = File.basename(@image_path)
      @file_size = File.size(@image_path)
      @blob = File.new(File.join(@data_path,'1/image'))

      @file_entity = FilePartUpload::FileEntity.new(:original => file_name, :file_size => @file_size)
      @file_entity.save
    }

    it{
      @file_entity.send(:merge)
      @file_entity.save

      expect {
        @file_entity.save_blob(@blob)
      }.to raise_error(FilePartUpload::AlreadyMergedError)

    }

    it{
      @file_entity.saved_size = 10
      @file_entity.save

      expect {
        @file_entity.save_blob(@blob)
      }.to raise_error(FilePartUpload::FileSizeOverflowError)

    }

  end

  describe '分段上传一个文件' do
    describe '文件分段数量是一' do
      before(:each){
        file_name = File.basename(@image_path)
        @file_size = File.size(@image_path)
        @blob = File.new(File.join(@data_path,'1/image'))

        @file_entity = FilePartUpload::FileEntity.new(:original => file_name, :file_size => @file_size)
        @file_entity.save
      }

      it{
        @file_entity.id.blank?.should == false
      }

      it{
        @file_entity.uploaded?.should == false
        @file_entity.uploading?.should == true
      }

      it{
        @file_entity.save_blob(@blob)
        @file_entity.uploaded?.should == true
        @file_entity.uploading?.should == false
      }

      it{
        @file_entity.save_blob(@blob)
        @file_entity.original.should == 'image.jpg'
        @file_entity.token.should_not == 'image.jpg'
        File.extname(@file_entity.token).should == '.jpg'
      }

      it{
        @file_entity.save_blob(@blob)
        File.exists?(@file_entity.path).should == true
        dir = File.join(FilePartUpload.root, "file_part_upload/file_entities/#{@file_entity.id}/attach")

        File.dirname(@file_entity.path).should == dir
        File.basename(@file_entity.path).should_not == 'image.jpg'
      }

      it{
        @file_entity.save_blob(@blob)
        url_dir = File.join("/file_part_upload/file_entities/#{@file_entity.id}/attach")
        File.dirname(@file_entity.url).should == url_dir
      }

      it{
        @file_entity.save_blob(@blob)
        @file_entity.file_size.should == @file_size
      }

      it{
        @file_entity.save_blob(@blob)
        @file_entity.mime.should == "image/jpeg"
      }
    end

    describe '文件分段数量是二' do
      before(:each){
        file_name = File.basename(@image_path)
        @file_size = File.size(@image_path)
        @blob_1 = File.new(File.join(@data_path,'2/image_split_aa'))
        @blob_2 = File.new(File.join(@data_path,'2/image_split_ab'))

        @file_entity = FilePartUpload::FileEntity.new(:original => file_name, :file_size => @file_size)
        @file_entity.save
      }

      it{
        @file_entity.id.blank?.should == false
      }

      it{
        @file_entity.uploaded?.should == false
        @file_entity.uploading?.should == true
      }

      it{
        @file_entity.save_blob(@blob_1)
        @file_entity.uploaded?.should == false
        @file_entity.uploading?.should == true
      }

      it{
        @file_entity.save_blob(@blob_1)
        @file_entity.save_blob(@blob_2)
        @file_entity.uploaded?.should == true
        @file_entity.uploading?.should == false
      }

      it{
        @file_entity.save_blob(@blob_1)
        @file_entity.save_blob(@blob_2)
        File.exists?(@file_entity.path).should == true
      }

      it{
        @file_entity.save_blob(@blob_1)
        @file_entity.save_blob(@blob_2)
        @file_entity.file_size.should == @file_size
      }

      it{
        @file_entity.save_blob(@blob_1)
        @file_entity.save_blob(@blob_2)
        @file_entity.mime.should == "image/jpeg"
      }
    end

    describe '文件分段数量是三' do
      before(:each){
        file_name = File.basename(@image_path)
        @file_size = File.size(@image_path)
        @blob_1 = File.new(File.join(@data_path,'3/image_split_aa'))
        @blob_2 = File.new(File.join(@data_path,'3/image_split_ab'))
        @blob_3 = File.new(File.join(@data_path,'3/image_split_ac'))

        @file_entity = FilePartUpload::FileEntity.new(:original => file_name, :file_size => @file_size)
        @file_entity.save
      }

      it{
        @file_entity.id.blank?.should == false
      }

      it{
        @file_entity.uploaded?.should == false
        @file_entity.uploading?.should == true
      }

      it{
        @file_entity.save_blob(@blob_1)
        @file_entity.uploaded?.should == false
        @file_entity.uploading?.should == true
      }

      it{
        @file_entity.save_blob(@blob_1)
        @file_entity.save_blob(@blob_2)
        @file_entity.uploaded?.should == false
        @file_entity.uploading?.should == true
      }

      it{
        @file_entity.save_blob(@blob_1)
        @file_entity.save_blob(@blob_2)
        @file_entity.save_blob(@blob_3)
        @file_entity.uploaded?.should == true
        @file_entity.uploading?.should == false
      }

      it{
        @file_entity.save_blob(@blob_1)
        @file_entity.save_blob(@blob_2)
        @file_entity.save_blob(@blob_3)
        File.exists?(@file_entity.path).should == true
      }

      it{
        @file_entity.save_blob(@blob_1)
        @file_entity.save_blob(@blob_2)
        @file_entity.save_blob(@blob_3)
        @file_entity.file_size.should == @file_size
      }

      it{
        @file_entity.save_blob(@blob_1)
        @file_entity.save_blob(@blob_2)
        @file_entity.save_blob(@blob_3)
        @file_entity.mime.should == "image/jpeg"
      }
    end

    describe '模仿 rails 表单上传' do
      before(:each){
        file_name = File.basename(@image_path)
        @file_size = File.size(@image_path)
        @file_blob_1 = File.new(File.join(@data_path,'3/image_split_aa'))
        @file_blob_2 = File.new(File.join(@data_path,'3/image_split_ab'))
        @file_blob_3 = File.new(File.join(@data_path,'3/image_split_ac'))

        @blob_1 = ActionDispatch::Http::UploadedFile.new({
            :filename => 'blob_1',
            :type => '',
            :tempfile => @file_blob_1
        })

        @blob_2 = ActionDispatch::Http::UploadedFile.new({
            :filename => 'blob_2',
            :type => '',
            :tempfile => @file_blob_2
        })

        @blob_3 = ActionDispatch::Http::UploadedFile.new({
            :filename => 'blob_3',
            :type => '',
            :tempfile => @file_blob_3
        })

        @file_entity = FilePartUpload::FileEntity.new(:original => file_name, :file_size => @file_size)
        @file_entity.save
      }

      it{
        @file_entity.id.blank?.should == false
      }

      it{
        @file_entity.uploaded?.should == false
        @file_entity.uploading?.should == true
      }

      it{
        @file_entity.save_blob(@blob_1)
        @file_entity.uploaded?.should == false
        @file_entity.uploading?.should == true
      }

      it{
        @file_entity.save_blob(@blob_1)
        @file_entity.save_blob(@blob_2)
        @file_entity.uploaded?.should == false
        @file_entity.uploading?.should == true
      }

      it{
        @file_entity.save_blob(@blob_1)
        @file_entity.save_blob(@blob_2)
        @file_entity.save_blob(@blob_3)
        @file_entity.uploaded?.should == true
        @file_entity.uploading?.should == false
      }

      it{
        @file_entity.save_blob(@blob_1)
        @file_entity.save_blob(@blob_2)
        @file_entity.save_blob(@blob_3)
        File.exists?(@file_entity.path).should == true
      }

      it{
        @file_entity.save_blob(@blob_1)
        @file_entity.save_blob(@blob_2)
        @file_entity.save_blob(@blob_3)
        @file_entity.file_size.should == @file_size
      }

      it{
        @file_entity.save_blob(@blob_1)
        @file_entity.save_blob(@blob_2)
        @file_entity.save_blob(@blob_3)
        @file_entity.mime.should == "image/jpeg"
      }

    end
  end

end
