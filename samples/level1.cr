require "../src/prism"
require "./level_map.cr"
require "./level.cr"
require "./player.cr"
require "./door.cr"

class Level1 < Level

    @obstacles = [] of Obstacle

    def initialize()
        super()
        @map = LevelMap.new("level0.png", "WolfCollection.png")
        self.add_component(@map)

        0.upto(@map.objects.size - 1) do |i|
            self.add_object(@map.objects[i])
        end

        player = Player.new(Vector2f.new(7, 7), self)
        self.add_object(player)

        @obstacles = @map.obstacles.dup()
    end

    def obstacles
        @obstacles
    end
end