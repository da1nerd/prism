# Prism
[![GitHub release](https://img.shields.io/github/release/neutrinog/prism.svg)](https://github.com/neutrinog/prism/releases)
[![Build Status](https://travis-ci.org/neutrinog/prism.svg?branch=master)](https://travis-ci.org/neutrinog/prism)

This is a stable, though not completely baked, 3D rendering engine. Documentation is a little sparse right now, but hopefully the [examples](./examples) will help. *Disclaimer:* I barely know anything about game development much less game engine development. This has been a learn-as-i-go project. If you have ideas or suggestions I would love it if you opened an [issue](https://github.com/neutrinog/prism/issues).


## Goals

* **Defaults** most things should "just work" with sane defaults.
* **Pure** other than a few system level dependencies, this should be 100% pure crystal code. Wrapping an existing project is cheating.
* **Simple** try to avoid obtuse graphics language, or at least document it very well so noobs can understand what's going on.
* **Extensible** you can extend/replace/add engines to the core with ease.

![Peek 2020-04-11 00-58](https://user-images.githubusercontent.com/166412/79012747-38b3c000-7b91-11ea-987d-37026e4052ab.gif)

<details>
  <summary>Click to see the demo code</summary>

```crystal
require "prism"

module Demo
  VERSION = "0.1.0"

  class Box < Prism::Core::GameEngine
    include Prism
    include Prism::Common
    alias Color = VMath::Vector3f
    def init
      green_material = Core::Material.new
      green_material.color = Color.new(0, 1, 0)

      red_material = Core::Material.new
      red_material.color = Color.new(1, 0, 0)

      floor = Objects::Plain.new(5, 5)
      floor.material = red_material
      add_object(floor)

      box = Objects::Cube.new(1)
      box.material = green_material
      box.move_north(2).move_east(2).elevate_by(1)
      add_object(box)

      sun_light = Core::Object.new
      sun_light.add_component(Light::DirectionalLight.new)
      sun_light.transform.look_at(box)
      add_object(sun_light)

      ambient_light = Core::Object.new
      ambient_light.add_component(Light::AmbientLight.new(Color.new(0.3, 0.3, 0.3)))
      add_object(ambient_light)

      camera = Objects::GhostCamera.new
      camera.move_east(3.5).elevate_by(0.5)
      camera.transform.look_at(box)
      add_object(camera)
    end
  end

  Prism::ContextAdapter::GLFW.run("Box", Box.new)
end
```

</details>

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  prism:
    github: neutrinog/prism
```

Install GLFW on your system


```bash
# on linux
sudo apt-get install libglfw3-dev

# on macOS
brew install glfw3
```

Install OpenGL

```bash
# on linux
sudo apt install mesa-common-dev

# on mac
# TODO: give install instructions
```

## Usage

```crystal
require "prism"
```

> TODO: write some usage example here.

For now you can run the same application in this repo.

```bash
make start
```

## Contributing

1. Fork it (<https://github.com/neutrinog/prism/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [neutrinog](https://github.com/neutrinog) Joel Lonbeck - creator, maintainer

## Special Thanks

This project was largely inspired by ["The Benny Box"](https://www.youtube.com/channel/UCnlpv-hhcsAtEHKR2y2fW4Q) and his [3D Game Engine Tutorial](https://www.youtube.com/watch?v=ss3AnSxJ2X8&list=PLEETnX-uPtBXP_B2yupUKlflXBznWIlL5&index=1). Thanks for all the good tutorials Benny!
