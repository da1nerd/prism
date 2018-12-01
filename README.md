# Prism

A 3D game engine written in Crystal!

This project was largely inspired by ["The Benny Box"](https://www.youtube.com/channel/UCnlpv-hhcsAtEHKR2y2fW4Q) and his [3D Game Engine Tutorial](https://www.youtube.com/watch?v=ss3AnSxJ2X8&list=PLEETnX-uPtBXP_B2yupUKlflXBznWIlL5&index=1). Thanks for all the good tutorials Benny!

This is a work in progress as I follow tutorials and wrap my head around game development.

## Demo
[This is a demo game](https://youtu.be/-IyXs2Dqs2o) that I hacked together using another tutorial. The source is under `samples` but be warned the code is quite ugly. This game simply illustrates that the engine actually works even with it's limited feature set.

[![Game demo](./samples/game_thumbnail.png)](https://youtu.be/-IyXs2Dqs2o)


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
install opengl `sudo apt install mesa-common-dev`

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
