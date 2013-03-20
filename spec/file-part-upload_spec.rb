require 'spec_helper'

class TestMigration < ActiveRecord::Migration
  def self.up
    create_table :file_entities, :force => true do |t|
      t.string   :attach_file_name
      t.string   :attach_content_type
      t.integer  :attach_file_size, :limit => 8
      t.integer  :saved_size,       :limit => 8
      t.boolean  :merged,           :default => false
      t.string   :md5
    end
  end

  def self.down
    drop_table :file_entities
  end
end

class FileEntity < ActiveRecord::Base
  file_part_upload
end

describe FilePartUpload::Base do
  before(:all){
    TestMigration.up
    @data_path = File.expand_path("../data",__FILE__)
    @image_path = File.join(@data_path, "image.jpg")
  }
  after(:all) {
    TestMigration.down
  }

  describe '字段校验' do
    before(:each){
      @file_name = File.basename(@image_path)
      @file_size = File.size(@image_path)
      @blob = File.new(File.join(@data_path,'1/image'))

    }

    it{
      expect{
        FileEntity.create!(:attach_file_size => @file_size)
      }.to raise_error(ActiveRecord::RecordInvalid)
    }

    it{
      expect{
        FileEntity.create!(:attach_file_name => @file_name)
      }.to raise_error(ActiveRecord::RecordInvalid)
    }

  end

  describe '异常处理' do
    before(:each){
      file_name = File.basename(@image_path)
      @file_size = File.size(@image_path)
      @blob = File.new(File.join(@data_path,'1/image'))

      @file_entity = FileEntity.new(:attach_file_name => file_name, :attach_file_size => @file_size)
      @file_entity.save
    }

    it{
      @file_entity.merge
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
      before(:all){
        file_name = File.basename(@image_path)
        @file_size = File.size(@image_path)
        @blob = File.new(File.join(@data_path,'1/image'))

        @file_entity = FileEntity.new(:attach_file_name => file_name, :attach_file_size => @file_size)
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
        File.exists?(@file_entity.attach.path).should == true
        dir = File.join(FilePartUpload.root, "file_part_upload/file_entities/#{@file_entity.id}/attach")
        
        File.dirname(@file_entity.attach.path).should == dir
        File.basename(@file_entity.attach.path).should == 'image.jpg'
        File.extname(@file_entity.attach.path).should == '.jpg'
      }

      it{
        url_dir = File.join("/file_part_upload/file_entities/#{@file_entity.id}/attach")
        File.dirname(@file_entity.attach.url).should == url_dir
      }

      it{
        @file_entity.attach.size.should == @file_size
      }

      it{
        @file_entity.attach.content_type.should == "image/jpeg"
      }
    end

    describe '文件分段数量是二' do
      before(:all){
        file_name = File.basename(@image_path)
        @file_size = File.size(@image_path)
        @blob_1 = File.new(File.join(@data_path,'2/image_split_aa'))
        @blob_2 = File.new(File.join(@data_path,'2/image_split_ab'))

        @file_entity = FileEntity.new(:attach_file_name => file_name, :attach_file_size => @file_size)
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
        @file_entity.save_blob(@blob_2)
        @file_entity.uploaded?.should == true
        @file_entity.uploading?.should == false
      }

      it{
        File.exists?(@file_entity.attach.path).should == true
      }

      it{
        @file_entity.attach.size.should == @file_size
      }

      it{
        @file_entity.attach.content_type.should == "image/jpeg"
      }
    end

    describe '文件分段数量是三' do
      before(:all){
        file_name = File.basename(@image_path)
        @file_size = File.size(@image_path)
        @blob_1 = File.new(File.join(@data_path,'3/image_split_aa'))
        @blob_2 = File.new(File.join(@data_path,'3/image_split_ab'))
        @blob_3 = File.new(File.join(@data_path,'3/image_split_ac'))

        @file_entity = FileEntity.new(:attach_file_name => file_name, :attach_file_size => @file_size)
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
        @file_entity.save_blob(@blob_2)
        @file_entity.uploaded?.should == false
        @file_entity.uploading?.should == true
      }

      it{
        @file_entity.save_blob(@blob_3)
        @file_entity.uploaded?.should == true
        @file_entity.uploading?.should == false
      }

      it{
        File.exists?(@file_entity.attach.path).should == true
      }

      it{
        @file_entity.attach.size.should == @file_size
      }

      it{
        @file_entity.attach.content_type.should == "image/jpeg"
      }
    end

    describe '模仿 rails 表单上传' do
      before(:all){
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

        @file_entity = FileEntity.new(:attach_file_name => file_name, :attach_file_size => @file_size)
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
        @file_entity.save_blob(@blob_2)
        @file_entity.uploaded?.should == false
        @file_entity.uploading?.should == true
      }

      it{
        @file_entity.save_blob(@blob_3)
        @file_entity.uploaded?.should == true
        @file_entity.uploading?.should == false
      }

      it{
        File.exists?(@file_entity.attach.path).should == true
      }

      it{
        @file_entity.attach.size.should == @file_size
      }

      it{
        @file_entity.attach.content_type.should == "image/jpeg"
      }

    end
  end

  describe '一次上传整个文件' do
    before(:all){
      file_name = File.basename(@image_path)
      @file_size = File.size(@image_path)
      @image = File.new(@image_path)
      @file_entity = FileEntity.new(:attach => @image)
      @file_entity.save
    }

    it{
      @file_entity.id.blank?.should == false
    }

    it{
      @file_entity.uploaded?.should == true
      @file_entity.uploading?.should == false
    }

    it{
      File.exists?(@file_entity.attach.path).should == true
    }

    it{
      @file_entity.attach.size.should == @file_size
    }

    it{
      @file_entity.attach.content_type.should == "image/jpeg"
    }
  end

  describe '模仿 rails 表单 一次上传整个文件' do
    before(:all){
      @file_size = File.size(@image_path)
      image_file = File.new(@image_path)
      @image = ActionDispatch::Http::UploadedFile.new({
          :filename => 'image.jpg',
          :type => '',
          :tempfile => image_file
      })

      @file_entity = FileEntity.new(:attach => @image)
      @file_entity.save
    }

    it{
      @file_entity.id.blank?.should == false
    }

    it{
      @file_entity.uploaded?.should == true
      @file_entity.uploading?.should == false
    }

    it{
      File.exists?(@file_entity.attach.path).should == true
    }

    it{
      @file_entity.attach.size.should == @file_size
    }

    it{
      @file_entity.attach.content_type.should == "image/jpeg"
    }
  end

  describe '文件没有扩展名' do
    before(:all){
      image_file = File.new(File.join(@data_path,'1/image'))

      @image = ActionDispatch::Http::UploadedFile.new({
          :filename => 'image',
          :type => '',
          :tempfile => image_file
      })

      @file_entity = FileEntity.new(:attach => @image)
      @file_entity.save
    }

    it{
      @file_entity.attach_content_type.should == 'application/octet-stream'
    }

    it{
      File.exists?(@file_entity.attach.path).should == true
      dir = File.join(FilePartUpload.root, "file_part_upload/file_entities/#{@file_entity.id}/attach")
      
      File.dirname(@file_entity.attach.path).should == dir
      File.basename(@file_entity.attach.path).should_not == 'image'
      File.extname(@file_entity.attach.path).should == ''
      @file_entity.attach.path[-1].should_not == '.'
    }

    it{
      url_dir = File.join("/file_part_upload/file_entities/#{@file_entity.id}/attach")
      File.dirname(@file_entity.attach.url).should == url_dir
    }
  end

end