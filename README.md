# prism

A cross between a game engine and a UI toolkit.
This is mostly a thought experiment and it may turn out to be nothing.

Once I get far enough along I'll re-organize all-the-things so it's a modular engine instead of just a hacky-not-usable-library.

I hope this will be usable on Windows some day. But that depends on [Crystal](https://github.com/crystal-lang/crystal/wiki/Platform-Support) which is still in beta.

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
For now you can't really use it because it's still under development. But you can run the sample application.

```bash
make start
```

## Development

TODO: Write development instructions here.

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
