---
layout: default
title: Introduction
nav_order: 4
---

# What is tidyverse?

R packages allow you to use additional functions that are not pre-programmed as part of base R.

The tidyverse package, is a package of packages that allows users to load in common packages quickly, rather than one at at time.

Tidyverse is very well maintained and has a very wide community of users. See their site with information about their mission and for additional tutorials

<https://www.tidyverse.org/>

There are other UBC libraries workshops that might be of interest and are related to this one

<https://ubc-library-rc.github.io/relational-data-r/>

<https://ubc-library-rc.github.io/data-manipulation-dplyr/>

# Installing and loading tidyverse

Like every other R package, you have to install tidyverse with `install.packages("tidyverse")` the first time you use it, and then only load it with`library(tidyverse)` in after that.

Input

``` r
# install
install.packages("tidyverse")

# load for use
library(tidyverse)
```

![](images/library_tidyverse.png)

After running the `library(tidyverse)` command, you will see some **core tidyverse packages** and some **conflicts** in your console. It's okay to have conflicts most of the time. Today, we will focus on some of the core tidyverse packages.
