---
layout: default
title: Tidyverse components
nav_order: 4
---

# Let's wrangle and plot some data

## tidyr

tidyr is a package that allows easy data manipulation. To see the full options and a tidyr cheat sheet, go to <https://tidyr.tidyverse.org>

Today, we will talk about pivoting data, which is an important first step before analyzing and plotting data sets.

We will work with the iris data

```{r}
View(iris)
```

The iris data is currently in a "long" format, but we canmake it even longer

```{r}
iris.longer = iris %>% pivot_longer(cols=c(1:4), 
                                    names_to = "metric_name",
                                    values_to = "metric_value")

```

See how we went from 5 columns to 3? How did the data structure change?

## dplyr

dplyr is a package that helpls with summarizing data. For the full list of what that means go here <https://dplyr.tidyverse.org>

Let's say we want to find some means and sample numbers in the iris.long dataset

```{r}
iris.summarised = iris.longer %>% 
  group_by(Species, metric_name) %>%
  summarise(
    sample.size = length(metric_value),
    metric.mean = mean(metric_value) 
    )
```

We are going to keep using dplyr and use a cheat to add the summarized data back into the longer iris dataset.

```{r}
iris.full = full_join(iris.longer, iris.summarised)

```

How did this join work? Do you know of other joins?

## ggplot2

ggplot2 is is a plotting package that is highly customizable. For the full resources go here <https://ggplot2.tidyverse.org>

```{r}
ggplot(iris.full, aes(x=Species))+
  geom_boxplot(aes(y=metric_value, color=Species))+
  geom_point(aes(y=metric.mean, color=Species), cex=3, pch=8)+
  facet_wrap(.~metric_name, scales="free")+
  scale_color_manual(values=c("#EE82EE", "#9400D3", "#483D8B"))+
  theme(axis.text = element_text(colour = "black", face = "bold", size = 12),
  legend.text = element_text(size = 8, face ="bold", colour ="black"),
  legend.title = element_text(size = 14, colour = "black", face = "bold"))
```

Spend the next 5 minutes removing and editing parts of this plot code to figure out what they do. 
Note down errors that you get and we can discuss them and how to troubleshoot errors as a group!
