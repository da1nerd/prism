require "../src/prism"
require "./level_map.cr"
require "./player.cr"
require "./door.cr"

class Level1 < GameObject


    def initialize()
        super()
        map = LevelMap.new("level0.png", "WolfCollection.png")
        self.add_component(map)

        player = Player.new(Vector2f.new(7, 7), map)
        self.add_object(player)


        material = Material.new
        material.add_texture("diffuse", Texture.new("WolfCollection.png"))
        material.add_float("specularIntensity", 1)
        material.add_float("specularPower", 8)
        door = GameObject.new.add_component(Door.new(material))
        door.transform.pos = Vector3f.new(7, 0, 7)

        self.add_object(door)
        
    end
end