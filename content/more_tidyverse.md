---
layout: default
title: More Tidyverse
nav_order: 6
---

# Optional More Tidyverse: going further

These sections continue from Working with Tidyverse. They use the same data and R script, and build on the `sgvp_flag` data frame we created in section 4.

## 6. Summarising by group

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

## 7. Sorting

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

## 8. Putting categories in order

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

## 9. Reshaping data

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

## 10. Joining data

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
