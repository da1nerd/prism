require "lib_glut"

module Prism
  class Timer
    SECOND = 1000000000
    @@delta : Float64 | Nil

    def self.get_time
      return LibGlut.get(LibGlut::ELAPSED_TIME)
    end

    def self.get_delta
      return @@delta
    end

    def self.set_delta(delta : Float64)
      @@delta = delta
    end
  end
end
