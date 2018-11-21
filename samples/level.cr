require "../src/prism"
require "./level_map.cr"
require "./player.cr"
require "./door.cr"

class Level < GameObject

    @obstacles = [] of Obstacle

    def initialize(level_name : String, texture_name : String, game : TestGame)
        super()
        @map = LevelMap.new(level_name, texture_name, game)
        self.add_component(@map)

        0.upto(@map.objects.size - 1) do |i|
            self.add_object(@map.objects[i])
        end
    end
end