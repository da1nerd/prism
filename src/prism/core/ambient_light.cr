require "./light"

module Prism::Core
  # Special alias to allow specifying an ambient light
  abstract class AmbientLight < Light
  end
end
