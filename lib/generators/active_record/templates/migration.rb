class CreateFilePartUpload < ActiveRecord::Migration
  def change
    create_table(:file_part_upload_file_entities) do |t|
      t.string :original
      t.string :mime
      t.string :kind
      t.string :token
      t.string :meta
      t.integer :saved_size
      t.boolean :merged, default: false

      t.timestamps
    end

    create_table(:file_part_upload_transcoding_records) do |t|
      t.string :name
      t.string :fops
      t.string :quniu_persistance_id
      t.string :token
      t.string :status
      t.string :meta
      t.integer :saved_size
      t.boolean :merged, default: false
      t.integer :file_entity_id

      t.timestamps
    end

    add_index(:file_part_upload_transcoding_records, :file_entity_id)
  end
end
