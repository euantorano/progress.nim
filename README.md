# progress.nim

A simple progress bar for Nim.

![Demo](https://raw.githubusercontent.com/euantorano/progress.nim/master/progress.gif)


## Usage

```nim
# os is only needed for `sleep`
import progress, os

let bar = newProgressBar()

bar.start()

for i in 1..100:
  # Do some work
  sleep(100)
  bar.increment()

bar.finish()
```
