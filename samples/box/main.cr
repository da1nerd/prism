require "../../src/prism/**"

class BoxDemo < Prism::Core::GameEngine
  alias Color = Prism::VMath::Vector3f

  def init
    material = Prism::Core::Material.new(File.join(File.dirname(PROGRAM_NAME), "/res/textures/defaultTexture.png"))
    brick_material = Prism::Core::Material.new(File.join(File.dirname(PROGRAM_NAME), "/res/textures/bricks.png"))

    # create a 5x5 floor
    floor = Prism::Common::Node::Plain.new(5, 5)
    floor.material = material

    # creates a 5x5 ceiling
    ceiling = Prism::Common::Node::Plain.new(5, 5)
    ceiling.material = material
    ceiling.reverse_face
    ceiling.elevate_to(5)

    # create a north wall that is 5x2
    north_wall = Prism::Common::Node::Plain.new(5, 5)
    north_wall.material = material
    north_wall.rotate_x_axis(Prism::VMath::Angle.from_degrees(-90)).move_north(5)
    # create a west wall that is 5x2
    west_wall = Prism::Common::Node::Plain.new(5, 5)
    west_wall.material = material
    west_wall.rotate_x_axis(Prism::VMath::Angle.from_degrees(-90))
    west_wall.rotate_y_axis(Prism::VMath::Angle.from_degrees(-90))

    # create a floating 1x1x1 box in the middle of the room
    box = Prism::Common::Node::Box.new(1)
    box.material = brick_material
    box.move_north(2).move_east(2).elevate_by(1)

    # create a second smaller box
    tiny_box = Prism::Common::Node::Box.new(0.5)
    tiny_box.material = brick_material
    tiny_box.move_north(3).move_east(3).elevate_by(0.5)

    # create a light with default values
    sun_light = Prism::Core::Object.new
    sun_light.add_component(Prism::Common::Light::DirectionalLight.new)
    sun_light.transform.look_at(box)

    point_light = Prism::Core::Object.new
    point_light.add_component(Prism::Common::Light::PointLight.new)
    point_light.move_north(2.5).move_east(1.5).elevate_by(1.5)

    spot_light = Prism::Core::Object.new
    spot_light.add_component(Prism::Common::Light::SpotLight.new)
    spot_light.move_north(3.5).move_east(2.5).elevate_by(1)

    # create some ambient light
    ambient_light = Prism::Core::Object.new
    ambient_light.add_component(Prism::Common::Light::AmbientLight.new(Color.new(0.5, 0.5, 0.5)))

    # creates a moveable camera with sane defaults
    camera = Prism::Core::Object.new
    camera.add_component(Prism::Core::Camera.new)
    camera.add_component(Prism::Common::Component::FreeLook.new)
    camera.add_component(Prism::Common::Component::FreeMove.new)
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
