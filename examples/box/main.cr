require "../../src/prism/**"

class BoxDemo < Prism::Core::GameEngine
  include Prism::Common
  alias Color = Prism::VMath::Vector3f

  def init
    material = Prism::Core::Material.new(File.join(__DIR__, "../res/textures/defaultTexture.png"))
    brick_material = Prism::Core::Material.new(File.join(__DIR__, "../res/textures/bricks.png"))
    green_material = Prism::Core::Material.new
    green_material.color = Color.new(0, 1, 0)

    # create a 5x5 floor
    floor = Node::Plain.new(5, 5)
    floor.material = material

    # creates a 5x5 ceiling
    ceiling = Node::Plain.new(5, 5)
    ceiling.material = material
    ceiling.reverse_face
    ceiling.elevate_to(5)

    # create a north wall that is 5x2
    north_wall = Node::Plain.new(5, 5)
    north_wall.material = material
    north_wall.rotate_x_axis(Prism::VMath::Angle.from_degrees(-90)).move_north(5)
    # create a west wall that is 5x2
    west_wall = Node::Plain.new(5, 5)
    west_wall.material = material
    west_wall.rotate_x_axis(Prism::VMath::Angle.from_degrees(-90))
    west_wall.rotate_y_axis(Prism::VMath::Angle.from_degrees(-90))

    # create a floating 1x1x1 box in the middle of the room
    box = Node::Cube.new(1)
    box.material = brick_material
    box.move_north(2).move_east(2).elevate_by(1)

    # create a second smaller box
    tiny_box = Node::Cube.new(0.5)
    tiny_box.material = green_material
    tiny_box.move_north(3).move_east(3).elevate_by(0.5)

    # create a light with default values
    sun_light = Prism::Core::Object.new
    sun_light.add_component(Light::DirectionalLight.new)
    sun_light.transform.look_at(box)

    point_light = Prism::Core::Object.new
    point_light.add_component(Light::PointLight.new(Prism::VMath::Vector3f.new(1, 0, 0)))
    point_light.move_north(2.5).move_east(1.5).elevate_by(1.5)

    spot_light = Prism::Core::Object.new
    spot_light.add_component(Light::SpotLight.new(Prism::VMath::Vector3f.new(0, 0.5, 0.5)))
    spot_light.move_north(4).move_east(4).elevate_by(1)
    spot_light.transform.rotate(Prism::VMath::Vector3f.new(1, 0, 0), -Prism::VMath.to_rad(70))

    # create some ambient light
    ambient_light = Prism::Core::Object.new
    ambient_light.add_component(Light::AmbientLight.new(Color.new(0.3, 0.3, 0.3)))

    # creates a moveable camera with sane defaults
    camera = Node::GhostCamera.new
    camera.move_east(3.5).elevate_by(0.5)
    camera.transform.look_at(box)

    # add everything to the scene
    add_object(ambient_light)
    add_object(sun_light)
    add_object(point_light)
    add_object(spot_light)
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

Prism::Adapter::GLFW.run("Box Demo", BoxDemo.new)
