require "./common"

module SeriousAkin
  class TrivialDatabase < Database
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
      @all_questions.select { |q| history[q]? == nil }.max_by do |q|
        st = Stats.new(0)
        @data.each do |(item, q1), ans|
          st[ans] += 1 if q1 == q && set.includes?(item)
        end
        {st[Answer::Yes], st[Answer::No]}.min
      end
    end

    def partition(set, question, answer)
      @data.each do |(item, q1), ans|
        next if q1 != question
        next if ans == answer || ans == Answer::Unknown
        set.delete item
      end
    end
  end
end
