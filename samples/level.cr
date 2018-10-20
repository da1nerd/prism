require "../src/prism"
require "./level_map.cr"
require "./player.cr"
# require "./detect_collision.cr"

class Level < GameObject


    def initialize(level_name : String, texture_name : String)
        super()
        map = LevelMap.new(level_name, texture_name)

        player = Player.new(Vector2f.new(7, 7), map)
        # player.add_component(DetectCollision.new(map, player))
        self.add_object(player)
        self.add_component(map)
    end
end