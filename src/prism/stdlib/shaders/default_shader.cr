require "baked_file_system"

module Prism
  # A light shader wrapper that loads shader programs from the code.
  # This is used for creating shaders in the stdlib.
  # If you want to create your own shader you should inherit from `Shader::Program` instead.
  # It would be nice if we had the backed file system built into this shader
  # so that subclasses can manualy bake their own shaders.
  # Keeping all the shaders in this single directory is messy.
  # TODO: allow shaders to bind their own shader files instead of using the defaults.
  #  This will allow grouping features together. e.g. all the skybox logic can go into a skybox folder.
  abstract class DefaultShader < Prism::Shader::Program
    protected def initialize(file_name : String)
      initialize file_name do |path|
        ShaderStorage.get(path).gets_to_end
      end
    end
  end

  # Stores a collection of glsl shader programs in a virtual file system.
  # This makes the shaders portable, since they are compiled into the program.
  private class ShaderStorage
    extend BakedFileSystem

    bake_folder "./default_shaders"
  end
end
