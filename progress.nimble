# Package

version       = "1.1.1"
author        = "Euan T"
description   = "A simple progress bar for Nim."
license       = "BSD3"

srcDir = "src"

# Dependencies

requires "nim >= 0.13.0"

task docs, "Build documentation":
  exec "nim doc2 --index:on -o:docs/progress.html src/progress.nim"
