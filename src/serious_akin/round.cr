require "kemal-session"
require "./common.cr"
require "./trivial.cr"

module SeriousAkin
  enum ActionType
    Question
    Guess
    Input
    Win
    Restart
  end

  alias Action = {ActionType, String}

  RESTART = {RoundAction::Restart, ""}

  class Round
    JSON.mapping({
      history:     History,
      last_action: Action,
      counter:     Int32,
    })
    include Session::StorableObject

    getter next_action = {RoundAction::Restart, ""}

    def db
      TrivialDatabase.instance
    end

    def initialize
      @history = History.new
      @last_action = RESTART
      @counter = 0
    end

    def gen_set
      set = db.all_items
      history.each { |q, ans| db.partition(set, q, and) }
    end

    def gen_next_question
      set = gen_set
      if set.size > 1
        @next_action = {RoundAction::Question, db.best_question(set, history)}
      else
        @next_action = {RoundAction::Guess, set.first || ""}
      end
    end

    def process_start
      @history.clear
      gen_next_question
    end

    def process_question(answer)
      history[question] = ans
      gen_next_question
    end

    def process_guess(ok : Bool)
      if ok
        @next_action = {RoundAction::Won, ""}
      else
        @next_action = {RoundAction::Input, @last_action[1]}
      end
    end

    def process_input(what, diff)
      db.add_record what, diff, history
      db.update_record @last_action[1], {diff => Answer::No}
      @next_action = RESTART
    end
  end
end
