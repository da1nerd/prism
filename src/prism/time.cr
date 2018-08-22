require "time"

module Prism
  class Timer
    SECOND = 1000000000
    @@delta : Float64 | Nil

    def self.get_time
      return Time.new().millisecond
    end

    def self.get_delta
      return @@delta
    end

    def self.set_delta(delta : Float64)
      @@delta = delta
    end
  end
end
