require "lib_gl"
require "stumpy_png"
require "./resource_management/bitmap_resource"

module Prism
  # Represents a loaded bitmap
  class Bitmap
    @@loaded_bitmaps = {} of String => BitmapResource
    @resource : BitmapResource
    @file_name : String
    @width : LibGL::Int = 0
    @height : LibGL::Int = 0
    @num_channels : LibGL::Int = 0
    @pixels = [] of UInt8

    getter width, height

    def initialize(@file_name : String)
      if @@loaded_bitmaps.has_key?(@file_name)
        @resource = @@loaded_bitmaps[@file_name]
        @resource.add_reference
      else
        @resource = load_bitmap(@file_name)
        @@loaded_bitmaps[@file_name] = @resource
      end
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

    # garbage collection
    def finalize
      if @resource.remove_reference
        @@loaded_bitmaps.delete(@file_name)
      end
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
    def pixel(x : Int32, y : Int32) : Color
      offset = (x + y * @width) * @num_channels
      r = @pixels[offset]
      g = @pixels[offset + 1]
      b = @pixels[offset + 2]
      if alpha?
        a = @pixels[offset + 3]
        return Color.new(r, g, b, a)
      else
        return Color.new(r, g, b)
      end
    end

    # Sets a pixel value
    def set_pixel(x : Int32, y : Int32, color : Color)
      offset = (x + y * @width) * @num_channels
      @pixels[offset] = color.red
      @pixels[offset + 1] = color.green
      @pixels[offset + 2] = color.blue
      @pixels[offset + 3] = color.alpha
    end

    # Scales a 16 bit number to an 8 bit number preserving the relative size within the available bits
    def self.scale_u16_to_u8(val : UInt16) : UInt8
      return ((val.to_f32 / UInt16::MAX.to_f32) * UInt8::MAX.to_f32).to_u8
    end

    # Loads a bitmap
    private def load_bitmap(file_name : String) : BitmapResource
      ext = File.extname(file_name)

      # read bitmap data
      path = File.join(File.dirname(PROGRAM_NAME), file_name)
      puts "loading #{path}"
      canvas = StumpyPNG.read(path)
      # data = LibTools.load_png(path, out @width, out @height, out @num_channels)
      # create bitmap
      resource = BitmapResource.new

      # if data
      (0...canvas.width).each do |x|
        (0...canvas.height).each do |y|
          color = canvas.get(x, y)
          @pixels.push(Bitmap.scale_u16_to_u8(color.r))
          @pixels.push(Bitmap.scale_u16_to_u8(color.g))
          @pixels.push(Bitmap.scale_u16_to_u8(color.b))
          @pixels.push(Bitmap.scale_u16_to_u8(color.a))
        end
      end

      # size = @canvas.width * @canvas.height# @width * @height * @num_channels
      # 0.upto(size - 1) do |i|
      #   @pixels.push(data[i])
      # end

        # TODO: if opengl can take our pixel array as input we can free this bitmap data and let texture inherit from bitmap.

        # TODO: free image data from stbi. see LibTools.
        # e.g. stbi_image_free(data)
      # else
      #   puts "Error: Failed to load bitmap data from #{path}"
      #   exit 1
      # end
      return resource
    end
  end
end
