require "../src/prism"
require "./level_map.cr"
require "./player.cr"

class Level1 < GameObject


    def initialize()
        super()
        map = LevelMap.new("level0.png", "WolfCollection.png")

        player = Player.new(Vector2f.new(7, 7), map)
        self.add_object(player)
        self.add_component(map)
    end
end