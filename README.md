# Prism
[![GitHub release](https://img.shields.io/github/release/neutrinog/prism.svg)](https://github.com/neutrinog/prism/releases)
[![Build Status](https://travis-ci.org/neutrinog/prism.svg?branch=master)](https://travis-ci.org/neutrinog/prism)

A 3D rendering engine.

## Goals

* **Defaults** most things should "just work" with sane defaults.
* **Pure** other than a few system level dependencies, this should be 100% pure crystal code. Wrapping an existing project is cheating.
* **Simple** try to avoid obtuse graphics language, or at least document it very well.
* **Extensible** you can extend/replace/add engines to the core with ease.

![Peek 2020-04-11 00-58](https://user-images.githubusercontent.com/166412/79012747-38b3c000-7b91-11ea-987d-37026e4052ab.gif)

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