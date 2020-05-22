module Prism::Core
  # Internal clock
  # This simply keeps track of how many seconds have elapsed.
  struct Clock
    @@seconds : Float64 = 0
    class_getter seconds

    # Increments the clock by the *frame_time*
    def self.tick(frame_time : Float64)
      @@seconds += frame_time
    end

    # Sets the clock to 0
    def self.reset
      @@seconds = 0
    end

    # Sets the clock to a specific value.
    def self.reset(@@seconds : Float64)
    end
  end
end
