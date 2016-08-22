require 'rails_helper'

describe FilePartUpload::FileEntity do
  it{
    expect(create(:ppt_file_entity).ppt?).to be true
    expect(create(:ppt_file_entity, mime: "application/vnd.openxmlformats-officedocument.presentationml.presentation").ppt?).to be true
    expect(create(:ppt_file_entity, mime: "test").ppt?).to be false
  }
end

