require "../src/prism"
require "lib_gl"

#  Example creating a window
module Examples
  # TODO: eventually this will recieve an instance of a game class.
  game = Prism::MainComponent.new
  game.start
end
