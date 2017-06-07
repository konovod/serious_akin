require "kemal"
require "kemal-session"
require "secure_random"
require "./serious_akin"

Session.config.secret = SecureRandom.hex(64)

MAX_QUESTIONS = 20

def do_question(env, obj, text)
  obj.last_question = text
  env.session.object("history", obj)
  render "src/views/question.ecr", "src/views/layout.ecr"
end

def do_input(env, obj, text)
  obj.last_question = text
  env.session.object("history", obj)
  render "src/views/input.ecr", "src/views/layout.ecr"
end

def do_next_question(env, obj)
  obj.counter += 1
  if obj.counter < MAX_QUESTIONS
    do_question(env, obj, "Вопрос #{obj.counter}/#{MAX_QUESTIONS}: RRRRR?")
  else
    do_guess(env, obj, "DONT KNOW")
  end
end

get "/start" do |env|
  obj = SeriousAkin::Round.new
  do_next_question(env, obj)
end

get "/answer/:ans" do |env|
  obj = env.session.object("history").as(SeriousAkin::Round)
  obj.history[obj.last_question] =
    case env.params.url["ans"]
    when "yes"
      SeriousAkin::Answer::Yes
    when "no"
      SeriousAkin::Answer::No
    else
      SeriousAkin::Answer::Incorrect
    end
  do_next_question(env, obj)
end

error 404 do
  "This is a customized 404 page."
end
error 403 do
  "Access Forbidden!"
end
get "/" do |env|
  env.response.status_code = 403
end

Kemal.run
