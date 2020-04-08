## A simple progress bar for Nim

from strutils import repeat, formatFloat, ffDecimal
from terminal import terminalWidth

const
  DEFAULT_COMPLETE_CHAR = '='
  DEFAULT_INCOMPLETE_CHAR = '.'
  DEFAULT_COMPLETE_HEAD = '>'
  DEFAULT_LEFT_DELIM = '['
  DEFAULT_RIGHT_DELIM = ']'

type
  ProgressBar* = object
    ## A progress bar with a given length and step
    complete: char
    incomplete: char
    incompleteHead: char
    leftDelim: char
    rightDelim: char
    step: int
    width: int
    total: int64
    current: int
    output: File
  InvalidPositionError* = object of Exception
    ## Error raised if the position of a progress bar is changed to an invlaid value - either less than 0, or greater than the length of the bar.

proc newProgressBar*(total: int = 100, step: int = 1, width: int = -1, complete: char = DEFAULT_COMPLETE_CHAR,
  incomplete: char = DEFAULT_INCOMPLETE_CHAR, incompleteHead: char = DEFAULT_COMPLETE_HEAD,
  leftDelim: char = DEFAULT_LEFT_DELIM, rightDelim: char = DEFAULT_RIGHT_DELIM, output: File = stdout): ProgressBar =
  ## Create a new progress bar.
  ##
  ## - The `total` is the total number of steps required to fill the progrss bar. This defaults to `100`, with each step being a 1% increment.
  ## - The `step` determines how much progress `tick` makes towards the `total`.
  ## - If the provided `width` is less than 1, then the progress bar will fill the whole width of the temrinal window. Otherwise it will take `width` characters.
  ## - The `complete` parameter determines the character used to represent the completed portion of the progress bar. This defaults to `=`.
  ## - The `incomplete` parameter determines the character used to represent the incomplete portion of the progress bar. This default to `.`.
  ## - The `incompleteHead` parameter is used to provide a cap on the end of the progress bar whilst it is not completed. This defaults to `>`.
  ## - The `leftDelim` and `rightDelim` parameters are used to determine the delimeters used to enclose the progress bar.
  ## - The `output` parameter can be used to change the destination that the progress bar is written to. Byd efault it writes to `stdout`.
  let barWidth = if width < 1: terminalWidth() - (8 + len($total)) else: width

  result = ProgressBar(
    total: total,
    step: step,
    width: barWidth,
    complete: complete,
    incomplete: incomplete,
    incompleteHead: incompleteHead,
    leftDelim: leftDelim,
    rightDelim: rightDelim,
    current: 0,
    output: output
  )

proc isComplete*(pb: ProgressBar): bool =
  ## Check whether the progress bar is complete.
  result = pb.current == pb.total

proc isIncomplete*(pb: ProgressBar): bool =
  ## Check whether the progress bar is incomplete.
  result = pb.current != pb.total

proc currentPosition(pb: ProgressBar): int =
  ## Get the progress bar's current position.
  result = toInt(((toFloat(pb.current) * toFloat(pb.width)) / toFloat(pb.total)))

proc percent*(pb: ProgressBar): float =
  ## Get the progress bar's current completion percentage.
  result = toFloat(pb.current) / (toFloat(pb.total) / 100.0)

proc print(pb: ProgressBar) {.raises: [IOError], tags: [WriteIOEffect].} =
  ## Print the progress bar to stdout.
  let
    position = pb.currentPosition()
    isComplete = pb.isComplete()

  var completeBar = pb.complete.repeat(position)
  if not isComplete:
    completeBar = completeBar[0..^1] & pb.incompleteHead

  let
    incompleteBar = pb.incomplete.repeat(pb.width - position)
    percentage = formatFloat(pb.percent(), ffDecimal, 2) & "%"

  write(pb.output, "\r" & pb.leftDelim & completeBar & incompleteBar & pb.rightDelim & " " & percentage)
  flushFile(pb.output)

  if isComplete:
    pb.output.writeLine("")

proc start*(pb: ProgressBar) {.raises: [IOError], tags: [WriteIOEffect].} =
  ## Start the progress bar. This will write the empty (0%) bar to the screen, which may not always be desired.
  if pb.current == 0:
    pb.print()

proc tick*(pb: var ProgressBar, count: int) {.raises: [IOError], tags: [WriteIOEffect].} =
  ## Increment the progress bar by `count` places.
  pb.current += count
  if pb.current < 0:
    pb.current = 0
  if pb.current > pb.total:
    pb.current = pb.total
  pb.print()

proc increment*(pb: var ProgressBar) {.raises: [IOError], tags: [WriteIOEffect].} =
  ## Increment the progress bar by one step.
  pb.tick(pb.step)

proc set*(pb: var ProgressBar, pos: int) {.raises: [InvalidPositionError, IOError], tags: [WriteIOEffect].} =
  ## Set the progress bar's current position to `pos`.
  if pos < 0:
    raise newException(InvalidPositionError, "Position must be greater than 0")

  if pos > pb.total:
    raise newException(InvalidPositionError, "Position must be less than total")

  pb.current = pos
  pb.print()

proc finish*(pb: var ProgressBar) {.raises: [InvalidPositionError, IOError], tags: [WriteIOEffect].} =
  ## Set the progress bar's current position to completion.
  if pb.current != pb.total:
    pb.set(pb.total)

when isMainModule:
  from os import sleep

  proc main() =
    var pb = newProgressBar()

    echo "Doing some work..."
    pb.start()

    for i in 1..100:
      sleep(100)
      pb.increment()

    pb.finish()

  main()
