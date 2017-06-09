require "kemal-session"
require "./common.cr"
require "./trivial.cr"

module SeriousAkin
  enum ActionType
    Restart
    Question
    Guess
    Input
    Won
  end

  alias Action = {ActionType, String}

  RESTART = {ActionType::Restart, ""}

  class Round
    JSON.mapping({
      history:     History,
      last_action: Action,
      counter:     Int32,
    })
    include Session::StorableObject

    # def last_action
    #   {ActionType.new(@last_action_id), @last_action_str}
    # end

    getter next_action : Action = {ActionType::Restart, ""}

    def db
      TrivialDatabase.instance.not_nil!
    end

    def initialize
      @history = History.new
      @last_action = RESTART
      @counter = 0
    end

    def gen_set
      set = db.all_items.dup
      history.each { |q, ans| db.partition(set, q, ans) }
      set
    end

    def gen_next_question
      @counter += 1
      set = gen_set
      if set.size > 1 && @counter <= 20
        @next_action = {ActionType::Question, db.best_question(set, history)}
      else
        case set.size
        when 0
          @next_action = {ActionType::Input, ""}
        when 1
          @next_action = {ActionType::Guess, set.first}
        else
          @next_action = {ActionType::Guess, db.best_guess(set, history)}
        end
      end
    end

    def process_start
      @history.clear
      gen_next_question
    end

    def process_won
      @next_action = RESTART
    end

    def process_question(answer)
      history[last_action[1]] = answer
      gen_next_question
    end

    def process_guess(ok : Bool)
      if ok
        db.update_record last_action[1], history
        @next_action = {ActionType::Won, ""}
      else
        @next_action = {ActionType::Input, last_action[1]}
      end
    end

    def process_input(what, diff)
      db.add_record what, diff, history
      db.update_record last_action[1], {diff => Answer::No}
      @next_action = RESTART
    end
  end
end
