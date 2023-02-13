# 2021 Advent of Code

I attempted to the 2021 advent of code problems using R after completing the 2022 problems using Julia. Below are a few observations:

- Parsing the input is generally easier in R using the `tidyverse`. The main exception is defining regular expressions where escaping the `\` (i.e. `\\`) is a pain.

- The `purrr` package is great. Having the data as the first argument to `map`, `reduce` etc makes piping a breeze compared to equivalent functions in base R and Julia (where need to use anonymous functions all over the show).

- Experimented with the new `R7` class system a bit (e.g. day 2). This looks promising, hopefully it gets merged into base R soon.

- I found that I tended to avoid setting up custom structures to store data in R. Not sure if this is because I'm less familiar with this pattern (perhaps due to tidyverse philosophy of putting everything in a dataframe) or language ergonomics. Probably need to make a conscious effort to experiment with this more.  

- R's native data structures starts to hurt in the later problems. E.g.:

  - Lack of a decent dictionaries. Where the key is a string, can use `names` on vectors but when you need to key by more complex data structures, life gets hard.

  - Difficulty growing vectors. There are some problems where you can't know the length of vectors in advance. I think growing vectors using `c()` creates copies, so is slow. Alternatively, can start from a large vectors with `NA` to avoid the copies but then checking track of whats in the vector becomes a bit tedious (by either filtering out `NA` or keeping track of number of elements used). Julia is a lot nicer here where you can `push!` and `pop!` elements of vectors and provide size hints when initialising vectors.

  - Discovered the `collections` package which provides some useful data structures. These are definitely more memory efficient but some functionality is missing. E.g. on day 15, I tried using a `priority_queue` but the implementation does not let you modify the priority of items that are already in queue.

- Doing the AoC tree problems is not fun in R. For day 15, I tried to implement Dijkstras algorithm in base R but the performance was terrible (even with the help of the `collections` package). It might be possible to get an efficient version of the algorithm in R, getting there is a lot more challenging. 
