require "../src/prism"
require "lib_gl"

#  Example creating a window
module Example
  extend self

  WIDTH = 800
  HEIGHT = 600
  TITLE = "Sample Window"

  window = Prism::Window.new(WIDTH, HEIGHT, TITLE)

  window.on_keyboard do |char, x, y|
    puts "key press #{char} #{x} #{y}"
  end

  window.on_mouse do |button, state, x, y|
    puts "mouse click #{button} #{state} #{x} #{y}"
  end

  window.on_motion do |x, y|

  end

  window.on_passive_motion do |x, y|

  end

  # window.on_display do
  #
  # end

  window.open()

end
