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
  it "db add more records" do
    db.add_record "собака", "лает", {"длинный хвост" => Answer::Yes}
    db.all_questions.should contain "лает"
    db.all_items.should contain "собака"
    db.data.size.should eq 3
    db.data[{"собака", "длинный хвост"}].should eq Answer::Yes
    db.data[{"собака", "лает"}].should eq Answer::Yes
    db.data[{"кот", "лает"}].should eq Answer::Unknown
    db.data[{"кот", "длинный хвост"}].should eq Answer::Yes
  end

  it "selects best question" do
  end
end
