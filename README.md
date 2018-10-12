# Prism

A 3D game engine written in Crystal!

This project was largely inspired by ["The Benny Box"](https://www.youtube.com/channel/UCnlpv-hhcsAtEHKR2y2fW4Q) and his [3D Game Engine Tutorial](https://www.youtube.com/watch?v=ss3AnSxJ2X8&list=PLEETnX-uPtBXP_B2yupUKlflXBznWIlL5&index=1). Thanks for all the good tutorials Benny!

![](./samples/sample.png "Sample 3D Scene")


## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  prism:
    github: neutrinog/prism
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

> NOTE: You might need to manually make the c lib `cd src/prism/lib && cmake . && make`.
> I guess the shard `postinstall` script only runs if you are installing this as a dependency (annoying).

## Development

TODO: Write some half-decent development instructions here.

- install cmake
- install freeglut
- install opengl
- install crystal

Supporting libraires I've built/forked-and-modified for this project:

- [CrystGLUT](https://github.com/neutrinog/cryst_glut) - an OpenGL context toolkit that leverages [Freeglut](http://freeglut.sourceforge.net/).
- [LibGLUT](https://github.com/neutrinog/lib_glut) - [Freeglut](http://freeglut.sourceforge.net/) bindings for Crystal with some custom bindings of my own to support passing closure from Crystal to C.
- [LibGL](https://github.com/neutrinog/cryst_glut) - OpenGL bindings for Crystal.

## Contributing

I'm using this as a learning exercise by following along with [this tutorial](https://www.youtube.com/watch?v=ss3AnSxJ2X8&list=PLEETnX-uPtBXP_B2yupUKlflXBznWIlL5&index=1). But if you are super interested send me a message so we can coordinate maybe?

1. Fork it (<https://github.com/neutrinog/prism/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### Features

- [x] load models
- [x] load shaders
- [x] manipulate camera (awsd for movement, click mouse to capture and rotate, ESC to release mouse)
- [x] load textures
- [x] basic mouse capture
- [x] ambient lighting
- [x] directional lighting
- [x] specular reflection
- [x] point lights
- [x] spot lights

## Contributors

- [neutrinog](https://github.com/neutrinog) Joel Lonbeck - creator, maintainer
