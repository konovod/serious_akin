module SeriousAkin
  enum Answer
    Unknown
    Yes
    No
    Incorrect
  end

  enum RoundStage
    Question
    Guess
    Won
    Lost
  end

  alias Item = String
  alias Question = String

  alias History = Hash(Question, Answer)
  alias ItemSet = Set(Item)
  alias Stats = Hash(Answer, Int32)

  class Round
    @history = History.new
    @set = ItemSet.new
    getter stage = RoundStage::Question
    @db : Database

    def initialize(@db)
    end

    def next_question(output : IO)
    end

    def process_input(input : IO)
    end
  end

  class Database
    getter data = Hash({Item, Question}, Answer).new(Answer::Unknown)
    getter all_questions = Set(Question).new
    getter all_items = Set(Item).new

    def add_record(item, question, history = History.new)
      @all_items << item
      @all_questions << question
      @data[{item, question}] = Answer::Yes
      update_record(item, history)
    end

    def update_record(item, history)
      history.each do |q, ans|
        @data[{item, q}] = ans
      end
    end

    def best_question(set, history)
      @all_questions.select { |q| history[q]? }.max_by do |q|
        st = Stats.new(0)
        @data.each do |(item, q1), ans|
          st[ans] += 1 if q1 == q && set.contain?(item)
        end
        {st[Answer::Yes], st[Answer::No]}.min
      end
    end
  end
end
