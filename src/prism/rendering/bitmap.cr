require "lib_gl"
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
      return Color.new(r, g, b)
    end

    # Sets a pixel value
    def set_pixel(x : Int32, y : Int32, color : Color)
      offset = (x + y * @width) * @num_channels
      @pixels[offset] = color.red
      @pixels[offset + 1] = color.green
      @pixels[offset + 2] = color.blue
    end

    # Loads a bitmap
    private def load_bitmap(file_name : String) : BitmapResource
      ext = File.extname(file_name)

      # read bitmap data
      path = File.join(File.dirname(PROGRAM_NAME), file_name)
      data = LibTools.load_png(path, out @width, out @height, out @num_channels)

      # create bitmap
      resource = BitmapResource.new

      if data
        size = @width * @height * @num_channels
        0.upto(size - 1) do |i|
          @pixels.push(data[i])
        end

        # TODO: if opengl can take our pixel array as input we can free this bitmap data and let texture inherit from bitmap.

        # TODO: free image data from stbi. see LibTools.
        # e.g. stbi_image_free(data)
      else
        puts "Error: Failed to load bitmap data from #{path}"
        exit 1
      end
      return resource
    end
  end
end
