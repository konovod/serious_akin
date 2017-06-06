module SeriousAkin
  enum Answer
    Unknown
    Yes
    No
    Incorrect
  end

  # enum RoundStage
  #   Question
  #   Guess
  #   Won
  #   Lost
  # end
  #
  alias Item = String
  alias Question = String

  alias History = Hash(Question, Answer)
  alias ItemSet = Set(Item)
  alias Stats = Hash(Answer, Int32)

  # class Round
  #   @history = History.new
  #   @set = ItemSet.new
  #   getter stage = RoundStage::Question
  #   @db : Database
  #
  #   def initialize(@db)
  #   end
  #
  #   def next_question(output : IO)
  #   end
  #
  #   def process_input(input : IO)
  #   end
  # end

  abstract class Database
    abstract def add_record(item, question, history = History.new) : Nil
    abstract def update_record(item, history) : Nil
    abstract def best_question(set, history) : Question
    abstract def partition(set, question, answer)
  end
end
