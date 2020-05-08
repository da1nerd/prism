require "./serializable"
require "../reference_pool"

module Prism::Shader
  # Represents a shader program.
  # This utilizes a `ReferencePool(CompiledProgram)` in order to re-use shader programs.
  # Orphaned shaders will be garbage collected and their OpenGL resources released.
  #
  # The key feature of this class is you can bind to uniforms by name.
  # All of the complicated location binding is handled automatically.
  abstract class Program
    ReferencePool.create_persistent_pool(CompiledProgram) { }

    # Generates a uniform property.
    #
    # You can define uniforms a few different ways. Below are two examples that bind to the *projection_matrix* uniform.
    # ```
    # uniform projection_matrix, Matrix4f
    # uniform "projection_matrix", Matrix4f
    # ```
    #
    # Now on your `Shader::Program` instance you can set the uniform
    # ```
    # shader.projection_matrix = myMatrix
    # ```
    #
    # You can also use camel case for your *uniform* names. The generated methods will be underscored, but the uniform itself will remain camel case.
    # ```
    # uniform projectionMatrix, Matrix4f
    #
    # # later on...
    # shader.projection_matrix = myMatrix
    #
    # # in the glsl code..
    # uniform vec4 projectionMatrix
    # ```
    macro uniform(name, type)
      # Sets the value of the **{{name}}** uniform.
      def {{name.id.underscore}}=(value : {{type}})
        if value.is_a?(Shader::Serializable)
          _{{name.id}}_uniforms = value.to_uniform(true)
          _{{name.id}}_uniforms.each do |k, v|
            set_uniform("{{name.id}}.#{k}", v)
          end
        else
          set_uniform("{{name.id}}", value)
        end
      end
    end

    # Creates a new shader from *file_name*.
    #
    # The vertex and fragment shaders will be interpolated from *file_name*,
    # therefore *file_name* should be extension-less.
    #
    # Shader programs may include other files using the `#include "file.ext"` statement.
    # These includes are resolved by *shader_reader* which receives the name of the included file.
    #
    # > NOTE: *file_name* will be passed to *shader_reader* as well.
    #
    # ## Example
    #
    # ```
    # Shader.new "forward-point" do |path|
    #   File.read(File.join("my/shader/directory", path))
    #   # Ends up reading:
    #   # forward-point.vs
    #   # lighting.glh <- embeded into forward-point.vs
    #   # forward-point.fs
    # end
    # ```
    #
    def initialize(file_name : String, &shader_reader : String -> String)
      if !pool.has_key? file_name
        pool.add(file_name, Shader::Loader.load_program(file_name, &shader_reader))
      end

      initialize(pool.use(file_name), file_name)
    end

    # Creates a new shader
    private def initialize(@resource : CompiledProgram, @pool_key : String)
    end

    def finalize
      pool.trash(@pool_key)
    end

    # Binds the program to OpenGL so it can run.
    # First we enable the program, then we bind values to all of the uniforms.
    # Finally, we enable all of the attributes.
    def start
      LibGL.use_program(@resource.program)
      0.upto(@resource.num_attributes - 1) do |i|
        LibGL.enable_vertex_attrib_array(i)
      end
    end

    # Unbinds the program from OpenGL so it won't run.
    def stop
      0.upto(@resource.num_attributes - 1) do |i|
        LibGL.disable_vertex_attrib_array(i)
      end
      LibGL.use_program(0)
    end

    # Returns the location of the uniform variable.
    # This will raise an exception if uniform does not exist in the glsl program.
    @[Raises]
    private def get_uniform_location(name : String) : Int32
      if @resource.uniforms.has_key? name
        @resource.uniforms[name]
      else
        raise Exception.new "The uniform \"#{name}\" is not defined in your glsl code. Update your shader or remove \"#{name}\" from your Shader::Program."
      end
    end

    # Sets a texture uniform variable value.
    def set_uniform(name : String, value : Prism::Texture)
      slot = get_uniform_location(name)
      value.bind(slot)
      set_uniform(name, slot)
    end

    # Sets an integer uniform variable value
    def set_uniform(name : String, value : LibGL::Int)
      LibGL.uniform_1i(get_uniform_location(name), value)
    end

    # Sets a float uniform variable value
    def set_uniform(name : String, value : LibGL::Float)
      LibGL.uniform_1f(get_uniform_location(name), value)
    end

    # Sets a 3 dimensional float vector value to a uniform variable
    def set_uniform(name : String, value : Vector3f)
      LibGL.uniform_3f(get_uniform_location(name), value.x, value.y, value.z)
    end

    # Sets a 2 dimensional float vector value to a uniform variable
    def set_uniform(name : String, value : Vector2f)
      LibGL.uniform_2f(get_uniform_location(name), value.x, value.y)
    end

    # Sets a 4 dimensional matrix float value to a uniform variable
    def set_uniform(name : String, value : Matrix4f)
      LibGL.uniform_matrix_4fv(get_uniform_location(name), 1, LibGL::TRUE, value.as_array)
    end

    # Sets a boolean uniform variable value.
    # Booleans are represented as floats in GLSL
    def set_uniform(name : String, value : Bool)
      LibGL.uniform_1f(get_uniform_location(name), value ? 1.0 : 0.0)
    end
  end
end
