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

## (1) Loading the tidyverse package

Install the tidyverse. You only need to do this once on your computer! If you haven't installed it yet, remove the `#` and run this line:

``` r
# install.packages("tidyverse")
```

Load the tidyverse. You need to do this in every R session:

``` r
library(tidyverse)
```

After running the `library(tidyverse)` command, you will see some **core tidyverse packages** and some **conflicts** in your console.

When we load the tidyverse we automatically load 9 commonly used packages. If you go to the Packages tab in the bottom right of RStudio, you can see which packages are loaded into your R session.

{: .note }
It's okay to have conflicts most of the time. Today, we will focus on some of the core tidyverse packages.

## (2) Reading data

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

When the data loads, `read_csv()` prints a short report:

```
Rows: 26678 Columns: 10
── Column specification ─────────────────────────
Delimiter: ","
chr (6): province, age_group, gender, education, volunteer, donor
dbl (4): id, weight, volunteer_hours, donation_amount
```

This tells us how many rows and columns we have, and what type of data is in each column.

{: .note }
Not all data comes as a cav. Two other packages that can be used to load other data types are installed with tidyverse but will need to be loaded separately before you can use them:<br>
**readxl** reads Excel files: `library(readxl)` then `read_excel("file.xlsx")`<br>
**haven** reads files from other statistics software: `library(haven)` then `read_sav("file.sav")` for SPSS, `read_dta("file.dta")` for Stata, or `read_sas("file.sas7bdat")` for SAS


## (3) Choosing columns and rows

The `<-` saves the result as a new object. New objects appear in the Environment pane (top right), which shows how many rows (obs.) and columns (variables) each one has.

`select()` keeps the **columns** you name. For our question we only need these four columns:

``` r
sgvp_columns <- select(sgvp, age_group, gender, volunteer, weight)
```

`filter()` keeps the **rows** that meet a condition. Keep only people living in British Columbia:

``` r
sgvp_bc <- filter(sgvp, province == "British Columbia")
```

### The pipe

We can chain steps together with the pipe: keep people in BC, and then keep only the columns we need.

The pipe `|>` takes the result on its left and passes it to the function on its right. You can read it as "and then".

When we use the pipe, we first name the data we want to use, then list the functions we want to apply to it. We skip the data argument inside each function, because the pipe passes the data in for us.

``` r
sgvp_bc <- sgvp |>
  filter(province == "British Columbia") |>
  select(age_group, gender, volunteer, weight)
```

Notice we no longer write `sgvp` inside `filter()` or `select()`.

**Try it:** keep only the people who volunteered. How many rows are left?

<details><summary><strong> Answer </strong></summary>

<pre>
sgvp_volunteers <- sgvp |>
  filter(volunteer == "Volunteer")
</pre>

11,352 rows are left.

</details>

## (4) Creating new columns

We want to convert volunteer status to a number: 1 for volunteers and 0 for everyone else.

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

## (5) Summarising data

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

## (6) Summarising by group

`group_by()` splits the data into groups. Any `summarise()` that comes after it is calculated separately for each group, giving one row per group.

Volunteering rate for each age group:

``` r
rate_by_age <- sgvp_flag |>
  group_by(age_group) |>
  summarise(
    people        = n(),
    weighted_rate = weighted.mean(volunteer_flag, weight)
  )
```

You can group by more than one column. This gives one row for every combination of age group and gender:

``` r
rate_by_age_gender <- sgvp_flag |>
  group_by(age_group, gender) |>
  summarise(
    people        = n(),
    weighted_rate = weighted.mean(volunteer_flag, weight),
    .groups       = "drop"  # remove the grouping when we're done
  )
```

## (7) Sorting

`arrange()` sorts the rows by the values in a column, smallest to largest:

``` r
rate_lowest_first <- rate_by_age |>
  arrange(weighted_rate)
```

Put the column inside `desc()` to sort from largest to smallest:

``` r
rate_highest_first <- rate_by_age |>
  arrange(desc(weighted_rate))
```

You can sort by more than one column. This sorts by gender first, then by rate (largest first) within each gender:

``` r
rate_by_gender_sorted <- rate_by_age_gender |>
  arrange(gender, desc(weighted_rate))
```

`arrange()` on a text column sorts alphabetically. It can't put education levels in a custom order like "Less than high school" first. For that we need factors (next section).

## (8) Putting categories in order

Volunteering rate for each education level:

``` r
rate_by_education <- sgvp_flag |>
  group_by(education) |>
  summarise(
    people        = n(),
    weighted_rate = weighted.mean(volunteer_flag, weight)
  )
```

Look at the order of the rows. R has sorted the education levels alphabetically, which isn't intuitive here!

A **factor** is R's version of a categorical variable. Unlike plain text, a factor keeps a list of its categories (called **levels**) in a fixed order, and R uses that order in tables and plots.

``` r
sgvp_education <- sgvp_flag |>
  filter(education != "Not stated") |>    # != means "is not equal to"
  mutate(education = fct_relevel(education,
                                 "Less than high school",
                                 "Graduated from high school",
                                 "Post-secondary diploma",
                                 "University diploma"))
```

The category names must match the data exactly. If you make a typo, R will warn you about an "unknown level".

Now the summary makes more sense!

``` r
rate_by_education <- sgvp_education |>
  group_by(education) |>
  summarise(
    people        = n(),
    weighted_rate = weighted.mean(volunteer_flag, weight)
  )
```

## (9) Reshaping data

`rate_by_age_gender` is in **long** format. To compare men and women, it is easier to have them side by side, in **wide** format.

`pivot_wider()` spreads one column out into several:

- `names_from`: the column whose values become the new column names
- `values_from`: the column whose values fill in the new columns

``` r
rate_wide <- rate_by_age_gender |>
  select(age_group, gender, weighted_rate) |>
  pivot_wider(names_from = gender, values_from = weighted_rate)
```

`pivot_longer()` does the reverse: it gathers several columns into one.

## (10) Joining data

A join combines two datasets by matching rows on a column they share.

`rate_wide` has the rate for each gender, and `rate_by_age` has the rate for everyone. Let's put them in one table, matching rows on `age_group`.

First, keep the columns we need and give the rate a better name with `rename()`. For `rename()`, the new name goes on the left and the old name on the right:

``` r
rate_everyone <- rate_by_age |>
  select(age_group, weighted_rate) |>
  rename(everyone = weighted_rate)
```

`left_join()` keeps every row of the first dataset and adds the matching columns from the second:

``` r
rate_table <- rate_wide |>
  left_join(rate_everyone, by = "age_group")
```
