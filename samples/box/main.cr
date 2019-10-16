require "../../src/prism/**"

# This is all wishful thinking.
# If I could build a game, this is the way I'd like to build it.
# Hopefully this will give me ideas on how to build the engine.
class MyProgram < Prism::Game
    def init

        # set a default material to be applied to all shapes
        # set_default_material(Prism::Material.new())
        material = Prism::Material.new("defaultTexture.png")

        # create a 5x5 floor
        floor = Prism::Shapes::Plain.new(5, 5)
        floor.material = material

        # creates a 5x5 ceiling
        ceiling = Prism::Shapes::Plain.new(5, 5)
        ceiling.material = material
        ceiling.flip_face()
        ceiling.elevate_to(5)

        # create a north wall that is 5x2
        northWall = Prism::Shapes::Plain.new(5, 2)
        northWall.rotate_x_axis(Prism::Angle.from_degrees(90))
        northWall.move_north(5);

        # create a west wall that is 5x2
        westWall = Prism::Shapes::Plain.new(5, 2)
        westWall.rotate_x_axis(Prism::Angle.from_degrees(90))
        westWall.rotate_y_axis(Prism::Angle.from_degrees(90))

        # create a floating 1x1x1 box in the middle of the room
        box = Prism::Shapes::Box.new(1)
        box.move_north(2)
        box.move_east(2)
        box.elevate_by(1)

        # create a light with default values
        sunLight = Prism::Object.new
        sunLight.add_component(Prism::DirectionalLight.new)

        # creates a moveable camera with sane defaults
        camera = Prism::Object.new
        camera.add_component(Prism::Camera.new)
        camera.add_component(Prism::FreeLook.new)
        camera.add_component(Prism::FreeMove.new)
        camera.move_east(1)
        camera.elevate_by(0.5)

        # add everything to the scene
        add_object(floor)
        add_object(ceiling)
        add_object(northWall)
        add_object(westWall)
        add_object(box)
        add_object(sunLight)
        add_object(camera)

        # allow changing an object's axis as well.
        # obj.set_axis_position(0, 0, 0) # default position is front right bottom corner.
    end
end

engine = Prism::CoreEngine.new(800, 600, 60.0, "Box Demo", MyProgram.new)
engine.start