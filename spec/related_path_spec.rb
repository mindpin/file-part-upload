require 'spec_helper'

class RelatedFileEntityMigration < ActiveRecord::Migration
  def self.up
    create_table :related_file_entities, :force => true do |t|
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
    drop_table :related_file_entities
  end
end

class RelatedFileEntity < ActiveRecord::Base
  file_part_upload :path => 'xxx/:class/:id/file/:name'
end

describe 'related_path' do
  before(:all){
    RelatedFileEntityMigration.up
    data_path = File.expand_path("../data",__FILE__)
    image_path = File.join(data_path, "image.jpg")
    file = File.new(image_path)
    @entity = RelatedFileEntity.create(:attach => file)
  }
  after(:all) {
    RelatedFileEntityMigration.down
  }

  it{
    File.exists?(@entity.attach.path).should == true
    dir = File.join(FilePartUpload.root, "xxx/related_file_entities/#{@entity.id}/file")
    File.dirname(@entity.attach.path).should == dir
  }

  it{
    url_dir = File.join("/xxx/related_file_entities/#{@entity.id}/file")
    File.dirname(@entity.attach.url).should == url_dir
  }

end