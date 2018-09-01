module Prism
  class ResourceLoader

    # Loads a shader from the disk
    def load_shader(file_name : String) : String
      data : String
      File.open(File.join("./res/shaders/", file_name)) do |f|
        data = f.read
      end

      return data
    end

  end
end
