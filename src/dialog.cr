require "./serious_akin"

def input_str(msg)
  puts "#{msg}?"
  gets.chomp
end

def input_ans(msg) : SeriousAkin::Answer
  s = input_str "#{msg}(Д - Дa/Н - Нет/З - Затрудняюсь)"
  case s.locase[0]
  when "д", "y"
    Answer::Yes
  when "н", "n"
    Answer::No
  else
    Answer::Incorrect
  end
end

db = TrivialDatabase.new
db.add_record "кот", "длинный хвост"

loop do
  puts "-----------НОВЫЙ РАУНД----------"
  i = 1
  set = db.all_items.to_set
  while !set.size > 1
    question = db.best_question(set)
    ans = input_ans(question)
    set = db.partition(question)
  end
end
