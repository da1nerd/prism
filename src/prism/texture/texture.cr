require "./loader"

module Prism
  # Represents a texture that has been loaded into OpenGL.
  abstract class Texture
    ReferencePool.create_persistent_pool(UInt32) do |key, id|
      # delete the texture
      LibGL.delete_textures(1, pointerof(id))
    end

    # Returns the texture id.
    # TODO: this is dangerous since we are pooling textures.
    #  However, we need this for now until we can update the texture abstraction.
    getter id

    # Creates a new texture
    def initialize(@id : UInt32, @pool_key : String)
    end

    def finalize
      pool.trash(@pool_key)
    end

    # You must implement this method to activate the texture
    # and bind it to the sampler slot.
    abstract def bind(sampler_slot : LibGL::Int)
  end
end
