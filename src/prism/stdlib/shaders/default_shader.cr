require "baked_file_system"

module Prism
  # A light shader wrapper that loads shader programs from the code.
  # This is used for creating shaders in the stdlib.
  # If you want to create your own shader you should inherit from `Shader::Program` instead.
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
