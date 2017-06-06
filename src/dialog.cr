require "./serious_akin"

include SeriousAkin

def input_str(msg)
  puts "#{msg}?"
  gets.not_nil!.chomp
end

def input_ans(msg) : SeriousAkin::Answer
  s = input_str "#{msg}(Д - Дa/Н - Нет/З - Затрудняюсь)"
  case s.downcase[0]
  when 'д', 'y'
    Answer::Yes
  when 'н', 'n'
    Answer::No
  else
    Answer::Incorrect
  end
end

db = TrivialDatabase.new
db.add_record "кот", "длинный хвост"

loop do
  puts "-----------НОВЫЙ РАУНД----------"
  set = db.all_items.to_set
  history = History.new
  while set.size > 1
    question = db.best_question(set, history)
    ans = input_ans(question)
    db.partition(set, question, ans)
    history[question] = ans
  end
  guess = set.first.not_nil!
  case input_ans "Это #{guess}! Я угадал"
  when .no?
    what = input_str("Тогда кто это")
    diff = input_str("Чем отличается от #{guess}")
    db.add_record what, diff, history
    db.update_record guess, {diff => Answer::No}
  else
    puts "УРА"
  end
end
