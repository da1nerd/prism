require "baked_file_system"

module Prism::Core
  # Embeds the default shaders at compile time.
  class ShaderStorage
    extend BakedFileSystem

    bake_folder "./shaders"
  end
end
