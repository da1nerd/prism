require "./core/clock"

module Prism
  # Represents a scalable game clock.
  # With the `Clock` you can use the concept of 24 hour time in your game in a natural way.
  #
  # The `Clock` has a dual purpose. It can represent a point of time or a length of time.
  # This is because all it does is produce a single float value.
  #
  # Therefore `1:30` could mean one thirty an or one hour and 30 minutes. It all depends on your context.
  struct Clock
    # The length of a regular day in seconds
    REAL_DAY_LENGTH = (24 * 60 * 60).to_f64

    @@day_length : Float64 = REAL_DAY_LENGTH
    @real_seconds : Float64

    getter real_seconds

    # Creates a new `Clock` instance that corresponds to the given time.
    #
    # By default the `Clock` will use a standard day length. Meaning, 12:20 in the game corresponds to 12:20 in the real world or 44,400 seconds.
    # You can scale the day down to a smaller time frame by a number of seconds to *day_length*.
    #
    # ## Example
    #
    # Here we set the day length to 10 seconds. So noon would occur at 5 seconds.
    # ```
    # clock = Clock.new(hour: 12, day_length: 10)
    # clock.real_seconds # => 5
    # ```
    def initialize(hour : Int32 = 0, minute : Int32 = 0, second : Int32 = 0, day_length : Float64 = @@day_length)
      seconds : Float64 = 0
      seconds += hour * 60 * 60
      seconds += minute * 60
      seconds += second
      @real_seconds = (seconds / REAL_DAY_LENGTH * day_length) % day_length
    end

    def self.day_length
      @@day_length
    end

    def self.day_length=(@@day_length : Float64)
    end

    # :nodoc:
    protected def initialize(unsafe_real_seconds : Float64, day_length : Float64)
      @real_seconds = unsafe_real_seconds % day_length
    end

    # Creates a new `Clock` instance that corresponds to the current game time.
    def self.now(day_length : Float64 = @@day_length)
      new(unsafe_real_seconds: Core::Clock.seconds, day_length: day_length)
    end

    # Changes the current time.
    def self.set_time(clock : Prism::Clock)
      Prism::Core::Clock.reset(clock.real_seconds)
    end
  end
end
