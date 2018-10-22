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

        material = Material.new
        material.add_texture("diffuse", Texture.new("WolfCollection.png"))
        material.add_float("specularIntensity", 1)
        material.add_float("specularPower", 8)
        door = Door.new(material)
        door_obj = GameObject.new.add_component(door)
        door_obj.transform.pos = Vector3f.new(8, 0, 7)

        self.add_object(door_obj)
        
        @obstacles = @map.obstacles.dup()
        @obstacles.push(door.as_obstacle)
    end

    def obstacles
        @obstacles
    end
#     # Checks if a collision occured and stops movement along the appropriate axis.
#   def check_collision(old_pos : Vector3f, new_pos : Vector3f, object_width : Float32, object_length : Float32) : Vector3f
#     collision_vector = Vector2f.new(1, 1)
#     movement_vector = new_pos - old_pos

#     if movement_vector.length > 0
#         block_size = Vector2f.new(SPOT_WIDTH, SPOT_LENGTH)
#         object_size = Vector2f.new(object_width, object_length)

#         0.upto(map.obstacles.size - 1) do |i|
#           collision_vector = collision_vector * rect_collide(old_pos.xz, new_pos.xz, object_size, block_size * @walls[i], block_size)
#         end
#     end

#     return Vector3f.new(collision_vector.x, 0, collision_vector.y)
#   end

#   private def rect_collide(old_pos : Vector2f, new_pos : Vector2f, player_size : Vector2f, obj_pos : Vector2f, obj_size : Vector2f) : Vector2f
#     result = Vector2f.new(0, 0)

#     # x axis
#     # players right edge < objects left edge || players left edge > object's right edge
#     x_can_move = new_pos.x + player_size.x < obj_pos.x || new_pos.x - player_size.x > obj_pos.x + obj_size.x * obj_size.x
#     y_can_move = old_pos.y + player_size.y < obj_pos.y || old_pos.y - player_size.y > obj_pos.y + obj_size.y * obj_size.y
#     if x_can_move || y_can_move
#       result.x = 1f32
#     end


#     distance_to_right_edge = obj_pos.x - (old_pos.x + player_size.x)
#     distance_to_left_edge = (old_pos.x - player_size.x) - (obj_pos.x + obj_size.x * obj_size.x)

#     # y axis
#     x_can_move = old_pos.x + player_size.x < obj_pos.x || old_pos.x - player_size.x > obj_pos.x + obj_size.x * obj_size.x
#     y_can_move = new_pos.y + player_size.y < obj_pos.y || new_pos.y - player_size.y > obj_pos.y + obj_size.y * obj_size.y
#     if x_can_move || y_can_move
#       result.y = 1f32
#     end

#     return result
#   end

end