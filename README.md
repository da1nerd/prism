# Prism
[![GitHub release](https://img.shields.io/github/release/neutrinog/prism.svg)](https://github.com/neutrinog/prism/releases)
[![Build Status](https://travis-ci.org/neutrinog/prism.svg?branch=master)](https://travis-ci.org/neutrinog/prism)

This is a stable, though not completely baked, 3D game engine. Documentation is a little sparse right now, but hopefully the example linked below will help. *Disclaimer:* I barely know anything about game development much less game engine development. This has been a learn-as-i-go project. If you have ideas or suggestions I would love it if you opened an [issue](https://github.com/neutrinog/prism/issues).


## Goals

* **Defaults** most things should "just work" with sane defaults.
* **Pure** other than a few system level dependencies, this should be 100% pure crystal code. Wrapping an existing project is cheating.
* **Simple** try to avoid obtuse graphics language, or at least document it very well so noobs can understand what's going on.
* **Extensible** you can extend/replace/add engines to the core with ease.


## Demo

> NOTE: this was recorded at 5fps, but runs at 60fps.

![Peek 2020-04-29 09-53](https://user-images.githubusercontent.com/166412/80556931-6dcc6900-89ff-11ea-8c78-b7dd11345d30.gif)


You can find code for this demo at https://github.com/neutrinog/tutorial-game

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

class Game < Prism::GameEngine
  def init
    # Cube
    # TODO: draw a box to look at

    # Sun light
    sun = Prism::Entity.new
    sun_color = Prism::Maths::Vector3f.new(0.2, 0.2, 0.2)
    sun.add Prism::PointLight.new(sun_color)
    sun.transform.move_to(0, 10000, -7000)
    add_entity sun

    # Camera
    add_entity Prism::GhostCamera.new
  end
end

Prism::Context.run("Hello World", Game.new)
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
