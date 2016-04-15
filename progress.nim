# A simple progress bar for Nim

from strutils import repeat, formatFloat, ffDecimal

const DEFAULT_COMPLETE_STR = "="
const DEFAULT_INCOMPLETE_STR = "."
const DEFAULT_COMPLETE_HEAD = ">"
const DEFAULT_LEFT_DELIM = "["
const DEFAULT_RIGHT_DELIM = "]"

type
  ProgressBar* = ref ProgressBarObj
  ProgressBarObj* = object
    ## A progress bar with a given length and step
    complete: string
    incomplete: string
    incompleteHead: string
    leftDelim: string
    rightDelim: string
    step: int
    width: int
    total: int
    current: int
  InvalidPositionError* = object of Exception

proc newProgressBar*(total: int = 100, step: int = 1, width: int = 100, complete: string = DEFAULT_COMPLETE_STR,
  incomplete: string = DEFAULT_INCOMPLETE_STR, incompleteHead: string = DEFAULT_COMPLETE_HEAD,
  leftDelim: string = DEFAULT_LEFT_DELIM, rightDelim: string = DEFAULT_RIGHT_DELIM): ProgressBar =
  ## Create a new progress bar with a given `total`, `step` and `width`.
  var head = incompleteHead
  if incompleteHead == nil:
    head = incomplete
  return ProgressBar(total: total, step: step, width: width, complete: complete, incomplete: incomplete,
    incompleteHead: head, leftDelim: leftDelim, rightDelim: rightDelim, current: 0)

proc isComplete*(pb: ProgressBar): bool =
  ## Check whether the progress bar is complete.
  return pb.current == pb.width

proc isIncomplete*(pb: ProgressBar): bool =
  ## Check whether the progress bar is incomplete.
  return pb.current != pb.width

proc currentPosition(pb: ProgressBar): int =
  ## Get the progress bar's current position.
  return toInt(((toFloat(pb.current) * toFloat(pb.width)) / toFloat(pb.total)))

proc percent*(pb: ProgressBar): float =
  ## Get the progress bar's current completion percentage.
  return toFloat(pb.current) / (toFloat(pb.total) / 100.0)

proc print(pb: ProgressBar) {.raises: [IOError], tags: [WriteIOEffect].} =
  ## Print the progress bar to stdout.
  let position = pb.currentPosition()

  let isComplete = pb.isComplete()

  var completeBar = pb.complete.repeat(position)
  let capLength = len(pb.incompleteHead)
  if not isComplete:
    completeBar = completeBar[0..^capLength] & pb.incompleteHead

  let incompleteBar = pb.incomplete.repeat(pb.width - position)
  let percentage = formatFloat(pb.percent(), ffDecimal, 2) & "%"

  write(stdout, "\r" & pb.leftDelim & completeBar & incompleteBar & pb.rightDelim & " " & percentage)
  flushFile(stdout)

  if isComplete:
    stdout.writeLine("")

proc start*(pb: ProgressBar) {.raises: [IOError], tags: [WriteIOEffect].} =
  ## Start the progress bar. This will write the empty (0%) bar to the screen, which may not always be desired.
  if pb.current == 0:
    pb.print()

proc tick*(pb: ProgressBar, count: int) {.raises: [IOError], tags: [WriteIOEffect].} =
  ## Increment the progress bar by `count` places.
  pb.current += count
  if pb.current < 0:
      pb.current = 0
  if pb.current > pb.total:
    pb.current = pb.total
  pb.print()

proc increment*(pb: ProgressBar) {.raises: [IOError], tags: [WriteIOEffect].} =
  ## Increment the progress bar by one step.
  pb.tick(pb.step)

proc set*(pb: ProgressBar, pos: int) {.raises: [InvalidPositionError, IOError], tags: [WriteIOEffect].} =
  ## Set the progress bar's current position to `pos`.
  if pos < 0:
    raise newException(InvalidPositionError, "position must be greater than 0")

  if pos > pb.total:
    raise newException(InvalidPositionError, "position must be less than total")

  pb.current = if pos > 0 and pos <= pb.total: pos else: pb.current
  pb.print()

proc finish*(pb: ProgressBar) {.raises: [InvalidPositionError, IOError], tags: [WriteIOEffect].} =
  ## Set the progress bar's current position to completion.
  if pb.current != pb.total:
    pb.set(pb.total)