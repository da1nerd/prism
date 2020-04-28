require "render_loop"
require "crash"

module Prism
  # A game component is an enhancement that can be added to a game object
  # DEPRECATED This is holding together most of the code at the moment, but this will eventually be removed.
  abstract class Component < Crash::Component
    # DEPRECATED the components shouldn't have direct access to their parent.
    # setter parent
    # @parent : Prism::Entity = Prism::Entity.new
  end
end
