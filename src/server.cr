require "kemal"
require "kemal-session"
require "secure_random"
require "./serious_akin"

Session.config.secret = SecureRandom.hex(64)

MAX_QUESTIONS = 20

class UserStorableObject
  JSON.mapping({
    history:       SeriousAkin::History,
    last_question: String,
    counter:       Int32,
  })
  include Session::StorableObject

  def initialize(@history)
    @last_question = ""
    @counter = 0
  end
end

def do_question(env, obj, text)
  obj.last_question = text
  env.session.object("history", obj)
  render "src/views/question.ecr", "src/views/layout.ecr"
end

def do_guess(env, obj, text)
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
  obj = UserStorableObject.new(SeriousAkin::History.new)
  do_next_question(env, obj)
end

get "/answer/:ans" do |env|
  obj = env.session.object("history").as(UserStorableObject)
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

Kemal.run
