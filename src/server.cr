require "kemal"
require "kemal-session"
require "secure_random"
require "./serious_akin"
require "./serious_akin"

Session.config.secret = SecureRandom.hex(64)

db = SeriousAkin::TrivialDatabase.new
db.add_record "кот", "длинный хвост"
SeriousAkin::TrivialDatabase.instance = db

MAX_QUESTIONS = 20

def do_action(env, obj)
  text = obj.next_action[1]
  obj.last_action = obj.next_action
  env.session.object("history", obj)
  case obj.next_action[0]
  when .question?
    render "src/views/question.ecr", "src/views/layout.ecr"
  when .guess?
    render "src/views/guess.ecr", "src/views/layout.ecr"
  when .input?
    render "src/views/input.ecr", "src/views/layout.ecr"
  when .won?
    env.session.destroy
    render "src/views/won.ecr", "src/views/layout.ecr"
  else
    # env.session.destroy
    obj = SeriousAkin::Round.new
    obj.process_start
    do_action(env, obj)
  end
end

get "/start" do |env|
  obj = SeriousAkin::Round.new
  obj.process_start
  do_action(env, obj)
end

get "/answer/:ans" do |env|
  obj = env.session.object("history").as(SeriousAkin::Round)
  ans = SeriousAkin::Answer.parse? env.params.url["ans"]
  if ans
    obj.process_question ans
  end
  do_action(env, obj)
end

get "/guess/:ans" do |env|
  obj = env.session.object("history").as(SeriousAkin::Round)
  ans = env.params.url["ans"] != "no"
  obj.process_guess ans
  do_action(env, obj)
end

get "/save" do |env|
  obj = env.session.object("history").as(SeriousAkin::Round)
  obj.process_input env.params.query["what"], env.params.query["diff"]
  do_action(env, obj)
end

error 404 do
  text = "Страница не найдена"
  render "src/views/error.ecr", "src/views/layout.ecr"
end
error 403 do
  text = "Доступ запрещен"
  render "src/views/error.ecr", "src/views/layout.ecr"
end
get "/" do |env|
  env.response.status_code = 403
end

Kemal.run
