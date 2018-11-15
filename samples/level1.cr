require "../src/prism"
require "./level_map.cr"
require "./level.cr"
require "./player.cr"
require "./door.cr"

class Level1 < GameObject

    @obstacles = [] of Obstacle

    def initialize()
        super()
        @map = LevelMap.new("level0.png", "WolfCollection.png")
        self.add_component(@map)

        0.upto(@map.objects.size - 1) do |i|
            self.add_object(@map.objects[i])
        end
    end
end