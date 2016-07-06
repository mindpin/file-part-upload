FactoryGirl.define do
  factory :image_file_entity, class: FilePartUpload::FileEntity do
    original "1-120GQF34TY.jpg"
    mime "image/jpeg"
    kind "image"
    token "/f/IuR0fINf.jpg"
    meta "{\"file_size\":25067,\"image\":{\"rgba\":\"rgba(79,73,81,0)\",\"hex\":\"#4f4951\",\"height\":\"200\",\"width\":\"200\"}}"
  end
end
