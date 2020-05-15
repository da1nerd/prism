require "crash"
require "../input_receiver.cr"

module Prism
  class Skybox < Crash::Component
    include Prism::InputReceiver
    @activation_times : Array(Float64)
    @textures : Hash(Float64, Prism::TextureCubeMap)
    @time : Float64 = 0

    getter day_texture, night_texture, size

    def initialize(periods : Skybox::Period, size : Float32)
      initialize(periods, size, day_length, 10000, 1000)
    end

    def initialize(periods : Skybox::Period, size : Float32, day_length : Float32)
      initialize(periods, size, day_length, 1000)
    end

    # Creates a skybox different *periods* of the day/night.
    # The *size* of the skybox determins how large the sky will be.
    # The *day_length* controls how long a day/night cycle is in seconds.
    # The *time* is the time of day we will start at.
    # The *transition_durration* controls how long it takes to transition between periods.
    def initialize(periods : Array(Skybox::Period), @size : Float32, @day_length : Float32, time : Skybox::Time, transition_durration : Skybox::Time)
      @activation_times = [] of Float64
      @textures = Hash(Float64, Prism::TextureCubeMap).new

      # Scale times
      @time = Skybox::Time.scale(time, @day_length)
      @transition_durration = Skybox::Time.scale(transition_durration, @day_length)

      # build schedule
      periods.each do |p|
        scaled_time = p.activation_time.scale(@day_length)
        @activation_times << scaled_time
        @textures[scaled_time] = p.texture
      end

      # sort largest to smallest
      @activation_times.sort!.reverse!
    end

    # Increment the clock
    def input!(tick : RenderLoop::Tick, input : RenderLoop::Input, entity : Crash::Entity)
      @time = (@time + tick.frame_time) % @day_length
    end

    # Retrieves the current skybox values
    def get_values : Tuple(current_texture: Prism::TextureCubeMap, next_texture: Prism::TextureCubeMap, blend_factor: Float32)
      index = 0
      @activation_times.each do |t|
        if @time < t && time >= t - @transition_durration
          # transition from the previous period to this one
          prev_t = @activation_times[Math.abs(index - 1)]
          return {
            current_texture: @textures[prev_t],
            previous_texture: @textures[t],
            blend_factor: ((@time - t + @transition_durration) / @transition_durration).to_f32
          }
        elsif @time > t
          # Still in the previous period without any transition
          prev_t = @activation_times[Math.abs(index - 1)]
          return {
            current_texture: @textures[prev_t],
            previous_texture: @textures[t],
            blend_factor: 0
          }
        end
        index += 1
      end
      raise "The skybox time calculation is broken"
    end
  end


  class Skybox < Crash::Component

    # Represents a specific time of day in 24 hour time.
    struct Time
      # The length of a regular day in seconds
      REAL_DAY_LENGTH = 24 * 60 * 60

      getter hour, minute, second

      # Creates a new time of day
      def initialize(@hour : Float64, @minute : Float64, @second : Float64)
      end

      # Scales the time to fit within a certain *day_length*
      def scale(day_length : Float64) : Float64
        seconds : Float64 = 0
        seconds += @hour * 60 * 60
        seconds += @minute * 60
        seconds += @second
        Skybox.scale(seconds, day_length)
      end

      # Scales the time of dayh in *seconds* to fit within the *day_length*.
      # This will wrap the time to the next day if it overflows.
      def self.scale(seconds : Float64, day_length : Float64)
        (seconds % day_length) / REAL_DAY_LENGTH * day_length
      end
    end

    # Represents a period in which a texture is used in the skybox.
    struct Period
      getter activation_time, texture
      # Produces a period of day/night that will become actiev at the *activation_time*
      def initialize(@activation_time : Skybox::Time, @texture : Prism::TextureCubeMap)
      end
    end
  end
end
