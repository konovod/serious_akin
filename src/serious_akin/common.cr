module SeriousAkin
  enum Answer
    Unknown
    Yes
    No
    Incorrect
  end

  alias Item = String
  alias Question = String

  alias History = Hash(Question, Answer)
  alias ItemSet = Set(Item)
  alias Stats = Hash(Answer, Int32)

  abstract class Database
    abstract def add_record(item, question, history = History.new) : Nil
    abstract def update_record(item, history) : Nil
    abstract def best_question(set, history) : Question
    abstract def partition(set, question, answer)
  end
end
