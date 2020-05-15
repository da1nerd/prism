require "crash"
require "../input_receiver.cr"

module Prism
  class Skybox < Crash::Component
    include Prism::InputReceiver
    @activation_times : Array(Float64)
    @textures : Hash(Float64, Prism::TextureCubeMap)
    # TODO: it would be better if the game had a global world time that could be used elsewere in the game as well.
    #  Perhaps this could be something configured in the game class and passed to the input methods.
    @time : Float64 = 0
    @day_length : Float64
    @transition_durration : Float64

    getter day_texture, night_texture, size

    def initialize(periods : Array(Skybox::Period))
      initialize(periods, 1_200)
    end

    def initialize(periods : Array(Skybox::Period), day_length : Float32)
      initialize(periods, day_length, Skybox::Time.new(hour: 12), Skybox::Time.new(hour: 1), 500)
    end

    # Creates a skybox different *periods* of the day/night.
    # The *size* of the skybox determins how large the sky will be.
    # The *day_length* controls how long a day/night cycle is in seconds.
    # The *time* is the time of day we will start at.
    # The *transition_durration* controls how long it takes to transition between periods.
    def initialize(periods : Array(Skybox::Period), day_length : Float32, time : Skybox::Time, transition_durration : Skybox::Time, @size : Float32)
      @day_length = day_length.to_f64
      @activation_times = [] of Float64
      @textures = Hash(Float64, Prism::TextureCubeMap).new

      # Scale times
      @time = time.scale(@day_length)
      @transition_durration = transition_durration.scale(@day_length)

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
    def get_values : NamedTuple(current_texture: Prism::TextureCubeMap, next_texture: Prism::TextureCubeMap, blend_factor: Float32)
      index = 0
      @activation_times.each do |t|
        prev_index = (index + 1) % @activation_times.size
        if @time < t && @time >= t - @transition_durration
          # transition from the previous period to this one
          prev_t = @activation_times[prev_index]
          return {
            current_texture: @textures[prev_t],
            next_texture: @textures[t],
            blend_factor: ((@time - t + @transition_durration) / @transition_durration).to_f32
          }
        elsif @time > t
          # Still in this period without any transition
          prev_t = @activation_times[prev_index]
          return {
            current_texture: @textures[t],
            next_texture: @textures[prev_t],
            blend_factor: 0f32
          }
        elsif @time < t && prev_index == 0
          # Still in previous period without any transition
          prev_t = @activation_times[prev_index]
          return {
            current_texture: @textures[prev_t],
            next_texture: @textures[t],
            blend_factor: 0f32
          }
        end
        index += 1
      end
      raise "The skybox time calculation is broken"
    end
  end


  class Skybox < Crash::Component

    # Represents a specific time of day in 24 hour time.
    # TODO: change this to `WorldTime` and have it somewhere global
    struct Time
      # The length of a regular day in seconds
      REAL_DAY_LENGTH = 24 * 60 * 60

      getter hour, minute, second

      # Creates a new time of day
      def initialize(@hour : Float64 = 0, @minute : Float64 = 0, @second : Float64 = 0)
      end

      # Scales the time to fit within a certain *day_length*
      def scale(day_length : Float64) : Float64
        seconds : Float64 = 0
        seconds += @hour * 60 * 60
        seconds += @minute * 60
        seconds += @second
        Skybox::Time.scale(seconds, day_length)
      end

      # Scales the time of dayh in *seconds* to fit within the *day_length*.
      # This will wrap the time to the next day if it overflows.
      def self.scale(seconds : Float64, day_length : Float64)
        (seconds / REAL_DAY_LENGTH * day_length) % day_length
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
