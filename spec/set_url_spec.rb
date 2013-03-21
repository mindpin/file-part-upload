require 'spec_helper'

class SetUrlFileEntityMigration < ActiveRecord::Migration
  def self.up
    create_table :set_url_file_entities, :force => true do |t|
      t.string   :attach_file_name
      t.string   :attach_content_type
      t.integer  :attach_file_size, :limit => 8
      t.integer  :saved_size,       :limit => 8
      t.string   :saved_file_name
      t.boolean  :merged,           :default => false
      t.string   :md5
    end
  end

  def self.down
    drop_table :set_url_file_entities
  end
end

class SetUrlFileEntity < ActiveRecord::Base
  file_part_upload :url  => '/xxx/:class/:id/file/:name'
end

describe 'set_url' do
  before(:all){
    SetUrlFileEntityMigration.up
    data_path = File.expand_path("../data",__FILE__)
    image_path = File.join(data_path, "image.jpg")
    file = File.new(image_path)
    @entity = SetUrlFileEntity.create(:attach => file)
  }
  after(:all) {
    SetUrlFileEntityMigration.down
  }

  it{
    File.exists?(@entity.attach.path).should == true
    dir = File.join(FilePartUpload.root, "file_part_upload/set_url_file_entities/#{@entity.id}/attach")
    File.dirname(@entity.attach.path).should == dir
  }

  it{
    url_dir = File.join("/xxx/set_url_file_entities/#{@entity.id}/file")
    File.dirname(@entity.attach.url).should == url_dir
  }

end