require "./spec_helper"

include SeriousAkin
describe SeriousAkin do
  # TODO: Write tests

  db = Database.new

  it "db add records" do
    db.add_record "кот", "длинный хвост"
    db.all_questions.to_a.should eq ["длинный хвост"]
    db.all_items.to_a.should eq ["кот"]
    db.data.size.should eq 1
    db.data[{"кот", "длинный хвост"}].should eq Answer::Yes
  end
end
