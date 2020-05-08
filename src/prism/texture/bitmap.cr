require "lib_gl"
require "stumpy_png"

module Prism
  # Provides a resource wrapper around the image loading library.
  # This keeps the image loading abstracted from the engine thus enabling
  # it to be easily changed in the future.
  class Bitmap
    @file_name : String
    @width : LibGL::Int = 0
    @height : LibGL::Int = 0
    @num_channels : LibGL::Int = 0
    @pixels = [] of UInt8

    getter width, height

    def initialize(@file_name : String)
      load_bitmap(@file_name)
    end

    # Checks if the bitmap has an alpha channel
    def alpha?
      return @num_channels == 4
    end

    # Pre-multiplies the RGB values with the alpha
    def multiply_alpha! : Bitmap
      return self if @num_channels != 4

      0.upto(@width - 1) do |i|
        0.upto(@height - 1) do |j|
          offset = ((@width - i - 1) + j * @width) * @num_channels

          # multiply color channels by the alpha channel
          alpha = @pixels[offset + @num_channels - 1].to_f32 / 255f32
          0.upto(@num_channels - 2) do |c|
            @pixels[offset + c] = (@pixels[offset + c].to_f32 * alpha).floor.to_u8
          end
        end
      end
      self
    end

    # Flips the x-axis
    def flip_x
      temp = @pixels.clone
      0.upto(@width - 1) do |i|
        0.upto(@height - 1) do |j|
          original_offset = ((@width - i - 1) + j * @width) * @num_channels
          offset = (i + j * @width) * @num_channels

          # copy channels
          0.upto(@num_channels - 1) do |c|
            temp[offset + c] = @pixels[original_offset + c]
          end
        end
      end
      @pixels = temp
      self
    end

    # flips the y-axis
    def flip_y
      temp = @pixels.clone
      0.upto(@width - 1) do |i|
        0.upto(@height - 1) do |j|
          original_offset = (i + (@height - j - 1) * @width) * @num_channels
          offset = (i + j * @width) * @num_channels

          # copy channels
          0.upto(@num_channels - 1) do |c|
            temp[offset + c] = @pixels[original_offset + c]
          end
        end
      end
      @pixels = temp
      self
    end

    # Return all the pixels
    def pixels
      @pixels
    end

    # Retrieves a pixel's color value
    # Gives the pixel color found at *x* and *y*, (horizontal axis, vertical axis)
    def pixel(x : Int32, y : Int32) : ColorUInt8
      offset = (x + y * @width) * @num_channels
      r = @pixels[offset]
      g = @pixels[offset + 1]
      b = @pixels[offset + 2]
      if alpha?
        a = @pixels[offset + 3]
        return ColorUInt8.new(r, g, b, a)
      else
        return ColorUInt8.new(r, g, b)
      end
    end

    # Sets a pixel value
    def set_pixel(x : Int32, y : Int32, color : ColorUInt8)
      offset = (x + y * @width) * @num_channels
      @pixels[offset] = color.red
      @pixels[offset + 1] = color.green
      @pixels[offset + 2] = color.blue
      @pixels[offset + 3] = color.alpha
    end

    # Loads a bitmap
    private def load_bitmap(file_path : String)
      # read bitmap data
      canvas = StumpyPNG.read(file_path)

      # create bitmap
      @num_channels = 4
      @width = canvas.width
      @height = canvas.height
      (0...canvas.height).each do |y|
        (0...canvas.width).each do |x|
          color = canvas.get(x, y).to_rgba
          @pixels.push(color[0])
          @pixels.push(color[1])
          @pixels.push(color[2])
          @pixels.push(color[3])
        end
      end
    end
  end
end
