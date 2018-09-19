require "../src/prism/**"
require "./test_game"
require "lib_gl"

#  Example creating a window
module Prism
  engine = CoreEngine.new(800, 600, 60.0, "3D Game Engine", TestGame.new(800.0, 600.0))
  engine.start
end
