module Prism

  class Timer

    private SECOND = 1_000.0f64

    # Returns time in milliseconds
    def self.get_time : Float64
      # TODO: I'd like to get nano seconds from this
      return self.compute_millisecond / SECOND
    end

    # Computes the system time in milliseconds
    private def self.compute_millisecond
      {% if flag?(:darwin) %}
        ret = LibC.gettimeofday(out timeval, nil)
        raise Errno.new("gettimeofday") unless ret == 0
        timeval.tv_sec * 1_000 + timeval.tv_usec.to_i64
      {% else %}
        ret = LibC.clock_gettime(LibC::CLOCK_REALTIME, out timespec)
        raise Errno.new("clock_gettime") unless ret == 0
        timespec.tv_sec * 1_000 + timespec.tv_nsec / 1_000_000
      {% end %}
    end

    # TODO: provide the time in nanoseconds. Make sure all platforms support this
  end

end
