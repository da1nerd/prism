require "lib_gl"
require "./resource_management/bitmap_resource"

module Prism
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

    # garbage collection
    def finalize
      if @resource.remove_reference
        @@loaded_bitmaps.delete(@file_name)
      end
    end

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
    def set_pixel(x : Int32, y : Int32, value : UInt8)
      @pixels[x + y * @width] = value
    end

    # Loads a bitmap
    private def load_bitmap(file_name : String) : BitmapResource
      ext = File.extname(file_name)

      # read bitmap data
      path = File.join(File.dirname(PROGRAM_NAME), "/res/bitmaps/", file_name)
      data = LibTools.load_png(path, out @width, out @height, out @num_channels)

      # create bitmap
      resource = BitmapResource.new

      if data
        size = @width * @height * @num_channels
        0.upto(size - 1) do |i|
          @pixels.push(data[i])
        end

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
