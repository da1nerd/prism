require "../../src/prism/**"

class BoxDemo < Prism::Game
  def init
    material = Prism::Material.new("defaultTexture.png")
    brick_material = Prism::Material.new("bricks.png")

    # create a 5x5 floor
    floor = Prism::Shapes::Plain.new(5, 5)
    floor.material = material

    # creates a 5x5 ceiling
    ceiling = Prism::Shapes::Plain.new(5, 5)
    ceiling.material = material
    ceiling.reverse_face
    ceiling.elevate_to(5)

    # create a north wall that is 5x2
    north_wall = Prism::Shapes::Plain.new(5, 5)
    north_wall.material = material
    north_wall.rotate_x_axis(Prism::Angle.from_degrees(-90)).move_north(5)
    # create a west wall that is 5x2
    west_wall = Prism::Shapes::Plain.new(5, 5)
    west_wall.material = material
    west_wall.rotate_x_axis(Prism::Angle.from_degrees(-90))
    west_wall.rotate_y_axis(Prism::Angle.from_degrees(-90))

    # create a floating 1x1x1 box in the middle of the room
    box = Prism::Shapes::Box.new(1)
    box.material = brick_material
    box.move_north(2).move_east(2).elevate_by(1)

    # create a second smaller box
    tiny_box = Prism::Shapes::Box.new(0.5)
    tiny_box.material = brick_material
    tiny_box.move_north(3).move_east(3).elevate_by(0.5)

    # create a light with default values
    sun_light = Prism::Object.new
    sun_light.add_component(Prism::DirectionalLight.new)
    sun_light.transform.look_at(box)

    # create some ambient light
    ambient_light = Prism::Object.new
    ambient_light.add_component(Prism::AmbientLight.new(Prism::Vector3f.new(0.5, 0.5, 0.5)))

    # creates a moveable camera with sane defaults
    camera = Prism::Object.new
    camera.add_component(Prism::Camera.new)
    camera.add_component(Prism::FreeLook.new)
    camera.add_component(Prism::FreeMove.new)
    camera.move_east(3.5).elevate_by(0.5)
    camera.transform.look_at(box)

    # add everything to the scene
    add_object(ambient_light)
    add_object(sun_light)
    add_object(floor)
    add_object(ceiling)
    add_object(north_wall)
    add_object(west_wall)
    add_object(box)
    add_object(tiny_box)
    add_object(camera)

    # TODO: allow changing an object's center axis as well.
    #  You should be able to place the axis at any 3d point.
    # obj.set_axis_position(0, 0, 0) # default position is front right bottom corner.
  end
end

engine = Prism::CoreEngine.new(800, 600, 60.0, "Box Demo", BoxDemo.new)
engine.start
