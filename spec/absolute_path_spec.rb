require 'spec_helper'

class AbsoluteFileEntityMigration < ActiveRecord::Migration
  def self.up
    create_table :absolute_file_entities, :force => true do |t|
      t.string   :attach_file_name
      t.string   :attach_content_type
      t.integer  :attach_file_size, :limit => 8
      t.integer  :saved_size,       :limit => 8
      t.boolean  :merged,           :default => false
      t.string   :md5
    end
  end

  def self.down
    drop_table :absolute_file_entities
  end
end

class AbsoluteFileEntity < ActiveRecord::Base
  file_part_upload :path => '/tmp/xxx/:class/:id/file/:name'
end

describe 'absolute_path' do
  before(:all){
    AbsoluteFileEntityMigration.up
    data_path = File.expand_path("../data",__FILE__)
    image_path = File.join(data_path, "image.jpg")
    file = File.new(image_path)
    @entity = AbsoluteFileEntity.create(:attach => file)
  }
  after(:all) {
    AbsoluteFileEntityMigration.down
  }

  it{
    File.exists?(@entity.attach.path).should == true
    dir = "/tmp/xxx/absolute_file_entities/#{@entity.id}/file"
    File.dirname(@entity.attach.path).should == dir
    File.basename(@entity.attach.path).should_not == 'image.jpg'
    File.extname(@entity.attach.path).should == '.jpg'
  }

  it{
    url_dir = "/tmp/xxx/absolute_file_entities/#{@entity.id}/file"
    File.dirname(@entity.attach.url).should == url_dir
  }

end