#------------------------------------------------------------------------------#
# 
# INTRO TO TIDYVERSE
#
#------------------------------------------------------------------------------#

# Before you start: save this script and sgvp_2023_workshop.csv in the SAME 
# folder.

# In RStudio go to Session > Set Working Directory > To Source File Location

# This tells R to look for data in the same folder where the script you are 
# writing is saved.

#------------------------------------------------------------------------------#
# (1) LOADING THE TIDYVERSE PACKAGE
#------------------------------------------------------------------------------#

# Install tidyverse: only need to do this once on your computer!
# If you haven't installed it yet, remove the # and run this line:

# install.packages("tidyverse")

# Load tidyverse for use: need to do this in every R session
library(tidyverse)

# When we load tidyverse we automatically load 9 packages. If you go to the 
# packages tab to the bottom right in RStudio you can see what packages are  
# loaded into your R session. 

#------------------------------------------------------------------------------#
# (2) READING DATA
#------------------------------------------------------------------------------#

# We will use the 2023 Survey on Giving, Volunteering and Participating (SGVP) 
# from Statistics Canada. 

# Who volunteers in Canada? How does the volunteering rate differ by age group 
# and gender?

#read in survey data
sgvp <- read_csv("sgvp_2023_workshop.csv")

#------------------------------------------------------------------------------#
# (3) CHOOSING COLUMNS AND ROWS
#------------------------------------------------------------------------------#

# The <- saves the result as a new object. New objects appear in the
# Environment pane (top right), which shows how many rows (obs.) and
# columns (variables) each one has.

# select() keeps COLUMNS you name
# For our question we only need: sgvp, age_group, gender, volunteer, and weight

sgvp_columns <- #CODE HERE

# filter() keeps ROWS that meet a condition
# Keep only people living in British Columbia (province == "British Columbia")

sgvp_bc <- #CODE HERE

# We can chain steps together with a pipe operator:

# The pipe |> takes the result on its left and passes it to the function on
# its right. You can read it as "and then".

# When we use the pipe, we first name the data we want to use, then list the
# functions we want to use with this data. We skip the data argument inside each
# function, because the pipe passes the data in for us.

sgvp_bc <- sgvp |>
  filter(province == "British Columbia") |>
  select(age_group, gender, volunteer, weight)

#Notice we no longer write sgvp inside filter() or select().

#------------------------------------------------------------------------------#
# (4) CREATING NEW COLUMNS
#------------------------------------------------------------------------------#

# We want to convert volunteer status to a number: 1 for volunteers and 0 for 
# everyone else. We will create a new variable called volunteer_flag.

# mutate() adds a new column (or changes an existing one)
# mutate(new_variable = ?)

# if_else() checks a condition for each row:
# if_else(condition, value if TRUE, value if FALSE)
# if_else(volunteer == "Volunteer", 1, 0)

sgvp_flag <- sgvp |>
  mutate(#CODE HERE)

#------------------------------------------------------------------------------#
# (5) SUMMARISING DATA
#------------------------------------------------------------------------------#

# Now we want to calculate the percentage of people who volunteered. 

# The average of out new column of 1s and 0s is the proportion volunteers.

# summarise() collapses many rows into a single summary row
# n() counts the number of rows; mean() calculates the average

volunteer_rate <- sgvp_flag |>
  summarise(
    people = n(),
    #CODE HERE
  )

# Each statement inside summarise() becomes a column in the output, and each
# statement has two parts separated by =
#
#     rate   = mean(volunteer_flag)
#     ^^^^     ^^^^
#     label    function
#

# Not every person in the survey counts equally. The survey included more
# volunteers than their true share of the population, so volunteers are
# over-represented in our data. The weight column fixes this: each person's
# weight is the number of people in Canada they represent.

# weighted.mean() gives each person's answer the right amount of influence
volunteer_rate <- sgvp_flag |>
  summarise(
    people        = n(),
    rate          = mean(volunteer_flag),
    weighted_rate = weighted.mean(volunteer_flag, weight)
  )

# Other useful summary functions:
# Let's describe how many hours volunteers gave. Only volunteers have hours
# (everyone else is NA), so we keep just the volunteers first.
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

#==============================================================================#
# OPTIONAL SECTIONS
# If we run out of time, you can work through sections 6 to 10 on your own.
# They match the "More Tidyverse" page on the workshop website.
#==============================================================================#

#------------------------------------------------------------------------------#
# (6) SUMMARISING BY GROUP
#------------------------------------------------------------------------------#

# group_by() splits the data into groups. Any summarise() that comes after it
# is calculated separately for each group, giving one row per group.

# Volunteering rate for each age group (age_group)
rate_by_age <- sgvp_flag |>
  #CODE HERE 
  summarise(
    people        = n(),
    weighted_rate = weighted.mean(volunteer_flag, weight)
  )

# You can group by more than one column. This gives one row for every
# combination of age group and gender.
rate_by_age_gender <- sgvp_flag |>
  group_by(age_group, gender) |>
  summarise(
    people        = n(),
    weighted_rate = weighted.mean(volunteer_flag, weight),
    .groups       = "drop"  # remove the grouping when we're done
  )

#------------------------------------------------------------------------------#
# (7) SORTING
#------------------------------------------------------------------------------#

# arrange() sorts the rows by the values in a column, smallest to largest
# Let's sort the data by weighted_rate
rate_lowest_first <- rate_by_age |>
  #CODE HERE

# Put the column inside desc() to sort from largest to smallest
rate_highest_first <- rate_by_age |>
  arrange(desc(weighted_rate))

# You can sort by more than one column. This sorts by gender first, then by
# rate (largest first) within each gender.
rate_by_gender_sorted <- rate_by_age_gender |>
  arrange(gender, desc(weighted_rate))

# arrange() on a text column sorts alphabetically. It can't put education
# levels in a custom order like "less than high school" first. For that we
# need factors (next section).

#------------------------------------------------------------------------------#
# (8) PUTTING CATEGORIES IN ORDER
#------------------------------------------------------------------------------#

# Volunteering rate for each education level
rate_by_education <- sgvp_flag |>
  group_by(education) |>
  summarise(
    people        = n(),
    weighted_rate = weighted.mean(volunteer_flag, weight)
  )

# Look at the order of the rows. R has sorted the education levels
# alphabetically, which isn't intuitive here! 

# A FACTOR is R version of a categorical variable. Unlike plain text, a factor
# keeps a list of its categories (called LEVELS) in a fixed order, and R uses
# that order in tables and plots.

sgvp_education <- sgvp_flag |>
  filter(education != "Not stated") |>    # != means "is not equal to"
  mutate(education = fct_relevel(education,
                                 "Less than high school",
                                 "Graduated from high school",
                                 "Post-secondary diploma",
                                 "University diploma"))

# The category names must match the data exactly. If you make a typo, R will
# warn you about an "unknown level".

# Now the summary makes more sense!
rate_by_education <- sgvp_education |>
  group_by(education) |>
  summarise(
    people        = n(),
    weighted_rate = weighted.mean(volunteer_flag, weight)
  )

#------------------------------------------------------------------------------#
# (9) RESHAPING DATA
#------------------------------------------------------------------------------#

# rate_by_age_gender is in LONG format.

#To compare men and women, it is easier to have them side by side, WIDE format.

# pivot_wider() spreads one column out into several:
# - names_from:  the column whose values become the new column names (gender)
# - values_from: the column whose values fill in the new columns (weighted_rate)

rate_wide <- rate_by_age_gender |>
  select(age_group, gender, weighted_rate) |>
  #CODE HERE

# pivot_longer() does the reverse: it gathers several columns into one.

#------------------------------------------------------------------------------#
# (10) JOINING DATA
#------------------------------------------------------------------------------#

# A join combines two datasets by matching rows on a column they share.

# rate_wide has the rate for each gender, and rate_by_age has the rate for
# everyone. Let's put them in one table, matching rows on age_group.

# First, keep the columns we need and give the rate a better name with rename()
# For rename(), the new name goes on the left, old name on the right
rate_everyone <- rate_by_age |>
  select(age_group, weighted_rate) |>
  rename(everyone = weighted_rate)

# left_join() keeps every row of the first dataset and adds the matching
# columns from the second
rate_table <- rate_wide |>
  left_join(rate_everyone, by = "age_group")

