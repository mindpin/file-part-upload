FactoryGirl.define do
  factory :file_entity, class: FilePartUpload::FileEntity do
    factory :ppt_file_entity do
      original "账表算与传票算.ppt"
      mime "application/vnd.ms-powerpoint"
      token "kc/K8kmueMB.ppt"
      meta{
        {"file_size"=>297984}
      }
    end
  end
end
