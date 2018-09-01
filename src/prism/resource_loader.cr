module Prism
  class ResourceLoader

    # Loads a shader from the disk
    def self.load_shader(file_name : String) : String
      path = File.join(File.dirname(PROGRAM_NAME), "/res/shaders/", file_name)
      return File.read(path)
    end

  end
end
