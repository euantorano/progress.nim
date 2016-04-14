import progress, unittest

suite "progress tests":
  test  "create simple progress bar and check completion":
    let bar = newProgressBar()
    check bar.isComplete() == false
    check bar.isIncomplete() == true

  test "percentage calculation and set":
    let bar = newProgressBar()
    bar.set(50)
    check bar.percent() == 50.0

    bar.set(30)
    check bar.percent() == 30.0

    bar.set(75)
    check bar.percent() == 75.0

  test "increment":
    let bar = newProgressBar()

    for i in 1..10:
      bar.increment()
      check bar.percent() == toFloat(i)
