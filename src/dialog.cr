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
TrivialDatabase.instance = db

round = Round.new
loop do
  round.last_action = round.next_action
  case round.next_action[0]
  when .restart?
    puts "-----------НОВЫЙ РАУНД----------"
    # round = Round.new
    round.process_start
  when .question?
    ans = input_ans(round.next_action[1])
    round.process_question ans
  when .guess?
    ans = input_ans("Это #{round.next_action[1]}! Я угадал")
    round.process_guess ans == Answer::Yes
  when .input?
    what = input_str("Тогда кто это")
    diff = input_str("Чем отличается от #{round.last_action[1]}")
    round.process_input what, diff
  when .won?
    puts "УРА"
    db.load_str db.dump_str
    round.process_won
  end
end
