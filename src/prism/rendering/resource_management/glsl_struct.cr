module Prism
  # Represents a struct in GLSL
  struct GLSLStruct
    getter name, properties

    def initialize(@name : String, @properties : Array(GLSLProperty))
    end
  end

  # A property of a `GLSLStruct`
  struct GLSLProperty
    getter name, prop_type

    def initialize(@name : String, @prop_type : String)
    end
  end

  # maps a GLSLStruct to uniform values
  struct UniformStruct(T)
    getter name, properties

    def initialize(@name : String, @properties : Array(T))
    end
  end

  # Maps a GLSLProperty to a uniform value
  struct UniformProperty(T)
    property value
    getter name

    def initialize(@name : String, @value : T)
    end
  end
end
