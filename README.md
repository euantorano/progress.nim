# progress.nim ![Build Status](https://api.travis-ci.org/euantorano/progress.nim.svg)

A simple progress bar for Nim.

![Demo](https://raw.githubusercontent.com/euantorano/progress.nim/master/progress.gif)

## Installation

```
nimble install progress
```

## [API Documentation](https://htmlpreview.github.io/?https://github.com/euantorano/progress.nim/blob/master/docs/progress.html)

## Usage

```nim
# os is only needed for `sleep`
import progress, os

var bar = newProgressBar()
bar.start()

for i in 1..100:
  # Do some work
  sleep(100)
  bar.increment()

bar.finish()
```
