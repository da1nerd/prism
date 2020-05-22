require "crash"
require "../clock.cr"
require "../input_receiver.cr"

module Prism
  class Skybox < Crash::Component
    @activation_times : Array(Float64)
    @textures : Hash(Float64, Prism::TextureCubeMap)
    @transition_durration : Float64

    getter day_texture, night_texture, size

    def initialize(periods : Array(Skybox::Period))
      initialize(periods, 1_200)
    end

    def initialize(periods : Array(Skybox::Period))
      initialize(periods, Prism::Clock.new(hour: 12), Prism::Clock.new(hour: 1), 500)
    end

    # Creates a skybox with different *periods* of the day/night.
    # The *size* of the skybox determins how large the sky will be.
    # The *time* is the time of day we will start at.
    # The *transition_durration* controls how long it takes to transition between periods.
    def initialize(periods : Array(Skybox::Period), time : Prism::Clock, transition_durration : Prism::Clock, @size : Float32)
      @activation_times = [] of Float64
      @textures = Hash(Float64, Prism::TextureCubeMap).new

      @transition_durration = transition_durration.real_seconds

      # build schedule
      periods.each do |p|
        scaled_time = p.activation_time.real_seconds
        @activation_times << scaled_time
        @textures[scaled_time] = p.texture
      end

      # sort largest to smallest
      @activation_times.sort!.reverse!
    end

    # Retrieves the current skybox values
    def get_values : NamedTuple(current_texture: Prism::TextureCubeMap, next_texture: Prism::TextureCubeMap, blend_factor: Float32)
      time = Prism::Clock.now.real_seconds
      index = 0
      @activation_times.each do |t|
        prev_index = (index + 1) % @activation_times.size
        if time < t && time >= t - @transition_durration
          # transition from the previous period to this one
          prev_t = @activation_times[prev_index]
          return {
            current_texture: @textures[prev_t],
            next_texture:    @textures[t],
            blend_factor:    ((time - t + @transition_durration) / @transition_durration).to_f32,
          }
        elsif time > t
          # Still in this period without any transition
          prev_t = @activation_times[prev_index]
          return {
            current_texture: @textures[t],
            next_texture:    @textures[prev_t],
            blend_factor:    0f32,
          }
        elsif time < t && prev_index == 0
          # Still in previous period without any transition
          prev_t = @activation_times[prev_index]
          return {
            current_texture: @textures[prev_t],
            next_texture:    @textures[t],
            blend_factor:    0f32,
          }
        end
        index += 1
      end
      raise "The skybox time calculation is broken"
    end

    # Represents a period in which a texture is used in the skybox.
    struct Period
      getter activation_time, texture

      # Produces a period of day/night that will become actiev at the *activation_time*
      def initialize(@activation_time : Prism::Clock, @texture : Prism::TextureCubeMap)
      end
    end
  end
end
