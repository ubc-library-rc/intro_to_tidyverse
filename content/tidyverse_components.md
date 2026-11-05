---
layout: default
title: Working with Tidyverse
nav_order: 5
---

# Let's wrangle some data

## The data

We will use the 2023 Survey on Giving, Volunteering and Participating (SGVP) from Statistics Canada. Our question for today is:

**Who volunteers in Canada? How does the volunteering rate differ by age group and gender?**

Before we start, download these two files and save them in the **same** folder:

- <a href="{{ '/files/sgvp_2023_workshop.csv' | relative_url }}" download>Download the data (sgvp_2023_workshop.csv)</a>
- <a href="{{ '/files/tidyverse_workshop.R' | relative_url }}" download>Download the R script (tidyverse_workshop.R)</a>

{: .note }
This data set is adapted from Statistics Canada, Survey on Giving, Volunteering and Participating Public Use Microdata File, 2023.

### Setting the working directory

First, open the R script in RStudio.

The **working directory** is the folder R looks in when you ask it to open a file. We need it to be the folder where you saved the data and the R script.

In RStudio go to **Session > Set Working Directory > To Source File Location**. This sets the working directory to the folder where your R script is saved.

To check where R is looking, run:

``` r
getwd()
```

## 1. Loading the tidyverse package

Install the tidyverse. You only need to do this once on your computer! If you haven't installed it yet, run this line:

``` r
install.packages("tidyverse")
```

Next, load the tidyverse. You need to do this in every R session:

``` r
library(tidyverse)
```

After running the `library(tidyverse)` command, you will see some core tidyverse packages and some conflicts in your console.

When we load the tidyverse we automatically load 9 commonly used packages. If you go to the Packages tab in the bottom right of RStudio, you can see which packages are loaded into your R session.

{: .note }
It's okay to have conflicts most of the time! Conflicts tell us that two packages have a function with the same name. When this happens, R uses the version from the package that was loaded most recently.

## 2. Reading data

Our data is saved as a csv file. We can use the `read_csv()` function to import this data into R.

`read_csv()` loads the data as a **data frame**: R's version of a table. Each row is one observation (here, one person who answered the survey) and each column is one variable. Every column holds one type of data, for example all text or all numbers.

{: .note }
The tidyverse version of a data frame is called a **tibble**. You may see this word in R's output. A tibble works the same way as a data frame, but prints more neatly.

``` r
# read in survey data
sgvp <- read_csv("sgvp_2023_workshop.csv")
```

- The file name goes inside quotes. Because we set the working directory to the folder with our files, R knows where to find it. Alternatly, if you have not set a working directory you can specify the full file path. 
- `sgvp <-` saves the data as an object called `sgvp`, so we can use it in the rest of the workshop. You will see it appear in the Environment pane.

{: .note }
Not all data comes as a cav. Two other packages that can be used to load other data types are installed with tidyverse but will need to be loaded separately before you can use them:<br>
**readxl** reads Excel files: `library(readxl)` then `read_excel("file.xlsx")`<br>
**haven** reads files from other statistics software: `library(haven)` then `read_sav("file.sav")` for SPSS, `read_dta("file.dta")` for Stata, or `read_sas("file.sas7bdat")` for SAS


## 3. Choosing columns and rows

`select()` keeps the **columns** you name. For our question we only need these four columns:

``` r
sgvp_columns <- select(sgvp, age_group, gender, volunteer, weight)
```

`filter()` keeps the **rows** that meet a condition. Keep only people living in British Columbia:

``` r
sgvp_bc <- filter(sgvp, province == "British Columbia")
```

### The pipe

You will frequently see a pipe symbol in R code (`|>`). This is used to chain steps together: keep people in BC, and then keep only the columns we need.

The pipe `|>` takes the result on its left and passes it to the function on its right. You can read it as "and then".

When we use the pipe, we first name the data we want to use, then list the functions we want to apply to it. We skip the data argument inside each function, because the pipe passes the data in for us.

``` r
sgvp_bc <- sgvp |>
  filter(province == "British Columbia") |>
  select(age_group, gender, volunteer, weight)
```

Notice we no longer write `sgvp` inside `filter()` or `select()`.

## 4. Creating new columns

We want to create a new column that stores volunteer status as a number: 1 for volunteers and 0 for everyone else.

`mutate()` adds a new column (or changes an existing one):

``` r
mutate(new_variable = ?)
```

`if_else()` checks a condition for each row:

``` r
if_else(condition, value if TRUE, value if FALSE)
```

Putting them together:

``` r
sgvp_flag <- sgvp |>
  mutate(volunteer_flag = if_else(volunteer == "Volunteer", 1, 0))
```

## 5. Summarising data

Now we want to calculate the percentage of people who volunteered. The average of our new column of 1s and 0s is the proportion of volunteers.

`summarise()` collapses many rows into a single summary row. `n()` counts the number of rows; `mean()` calculates the average.

``` r
volunteer_rate <- sgvp_flag |>
  summarise(
    people = n(),
    rate   = mean(volunteer_flag)
  )
```

Each statement inside `summarise()` becomes a column in the output, and each statement has two parts separated by `=`:

```
    people = n()
    ^^^^^^   ^^^
    label    function
```

### Survey weights

Not every person in the survey counts equally. The survey included more volunteers than their true share of the population, so volunteers are over-represented in our data. The `weight` column fixes this: each person's weight is the number of people in Canada they represent.

`weighted.mean()` gives each person's answer the right amount of influence:

``` r
volunteer_rate <- sgvp_flag |>
  summarise(
    people        = n(),
    rate          = mean(volunteer_flag),
    weighted_rate = weighted.mean(volunteer_flag, weight)
  )
```

### Other useful summary functions

Let's describe how many hours volunteers gave. Only volunteers have hours (everyone else is `NA`), so we keep just the volunteers first.

``` r
hours_summary <- sgvp |>
  filter(volunteer == "Volunteer") |>
  summarise(
    people       = n(),                     # number of rows
    mean_hours   = mean(volunteer_hours),   # mean
    median_hours = median(volunteer_hours), # median
    min_hours    = min(volunteer_hours),    # minimum value
    max_hours    = max(volunteer_hours),    # maximum value
    sd_hours     = sd(volunteer_hours),     # standard deviation
    total_hours  = sum(volunteer_hours)     # sum
  )
```
