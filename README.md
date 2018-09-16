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

## Contributing

I'm using this as a learning exercise by following along with [this tutorial](https://www.youtube.com/watch?v=ss3AnSxJ2X8&list=PLEETnX-uPtBXP_B2yupUKlflXBznWIlL5&index=1). But if you are super interested send me a message so we can coordinate maybe?

1. Fork it (<https://github.com/neutrinog/prism/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [neutrinog](https://github.com/neutrinog) Joel Lonbeck - creator, maintainer
