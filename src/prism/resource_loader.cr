module Prism
  class ResourceLoader

    # Loads a shader from the disk
    def self.load_shader(file_name : String) : String
      return File.read(File.join("./res/shaders/", file_name))
    end

  end
end
