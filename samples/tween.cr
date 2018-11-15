# Produces tweened steps across a key frame
class Tween
    @frame : Int32
    @total_frames : Int32
    
    # *delta* is the period between each tweened frame
    # *key_frame_time* is the time alloted to the key frame being tweened
    def initialize(@delta : Float32, @key_frame_time : Float32)
        @frame = 0
        @total_frames = (@key_frame_time // @delta).to_i32
    end

    # Advances the tween by one frame and returns the progress
    def step : Float32
        if @frame < @total_frames
            @frame += 1
        end
        return get_step
    end

    # Returns the current tween progress
    def get_step : Float32
        return 0f32 unless @frame > 0
        return 1f32 unless @frame < @total_frames
        return @total_frames.to_f32 / @frame.to_f32
    end

    # Sets the tween progress back to the beginning
    def reset
        @frame = 0
    end
end