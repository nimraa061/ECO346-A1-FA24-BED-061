
# ECO346 Assignment 1 - Variant 5 (KP Urban)

library(dplyr)
library(ggplot2)

# Step 1: Read the two data files
person <- read.csv("data/pslm_person_subset.csv")
household <- read.csv("data/pslm_hh_subset.csv")

# Step 2: Join person and household data
person$hhid <- as.character(person$hhid)
household$hhid <- as.character(household$hhid)

data <- merge(
  person,
  household[, c("hhid", "hhweight", "prov_code", "urban_rural")],
  by = "hhid",
  all.x = TRUE
)

# Step 3: Select Variant 5 - KP Urban
sample_data <- data %>%
  filter(prov_code == 1, urban_rural == 2)

# Step 4: Select earners aged 15 to 64
earners <- sample_data %>%
  filter(
    age >= 15,
    age <= 64,
    earn_annual > 0
  )

# Step 5: Weighted quantile function
weighted_quantile <- function(x, w, p) {
  valid <- !is.na(x) & !is.na(w) & w > 0
  x <- x[valid]
  w <- w[valid]
  
  ord <- order(x)
  x <- x[ord]
  w <- w[ord]
  
  x[which(cumsum(w) / sum(w) >= p)[1]]
}

# Step 6: Question 2 - Earnings statistics
median_unweighted <- median(earners$earn_annual, na.rm = TRUE)

median_weighted <- weighted_quantile(
  earners$earn_annual, earners$hhweight, 0.50
)

p10_weighted <- weighted_quantile(
  earners$earn_annual, earners$hhweight, 0.10
)

p90_weighted <- weighted_quantile(
  earners$earn_annual, earners$hhweight, 0.90
)

ratio_p90_p10 <- p90_weighted / p10_weighted

excluded_count <- sum(
  earners$earn_annual < 10000 |
    earners$earn_annual > 10000000,
  na.rm = TRUE
)

cat("Number of earners:", nrow(earners), "\n")
cat("Unweighted median:", median_unweighted, "\n")
cat("Weighted median:", median_weighted, "\n")
cat("Weighted P10:", p10_weighted, "\n")
cat("Weighted P90:", p90_weighted, "\n")
cat("P90/P10 ratio:", round(ratio_p90_p10, 2), "\n")
cat("Observations outside plotting range:", excluded_count, "\n")

# Step 7: Prepare data for the weighted histogram
plot_earners <- earners %>%
  filter(
    earn_annual >= 10000,
    earn_annual <= 10000000,
    !is.na(hhweight),
    hhweight > 0
  )

plot_earners$log_income <- log10(plot_earners$earn_annual)

breaks <- seq(4, 7, by = 0.1)

bin_number <- cut(
  plot_earners$log_income,
  breaks = breaks,
  include.lowest = TRUE,
  right = FALSE,
  labels = FALSE
)

hist_data <- data.frame(
  bin = bin_number,
  weight = plot_earners$hhweight
) %>%
  filter(!is.na(bin)) %>%
  group_by(bin) %>%
  summarise(total_weight = sum(weight), .groups = "drop")

hist_data$midpoint <- 4 + (hist_data$bin - 0.5) * 0.1

hist_data$density <- hist_data$total_weight /
  sum(plot_earners$hhweight) / 0.1

# Question 2 histogram
p2 <- ggplot(hist_data, aes(x = midpoint, y = density)) +
  geom_col(width = 0.095, fill = "steelblue") +
  geom_vline(
    xintercept = log10(median_weighted),
    linetype = "dashed"
  ) +
  geom_vline(
    xintercept = log10(p90_weighted),
    linetype = "dashed"
  ) +
  annotate(
    "text",
    x = log10(median_weighted),
    y = max(hist_data$density) * 0.95,
    label = paste("Median:", format(median_weighted, big.mark = ",")),
    angle = 90, hjust = 1, vjust = -0.4, size = 3
  ) +
  annotate(
    "text",
    x = log10(p90_weighted),
    y = max(hist_data$density) * 0.95,
    label = paste("P90:", format(p90_weighted, big.mark = ",")),
    angle = 90, hjust = 1, vjust = -0.4, size = 3
  ) +
  scale_x_continuous(
    breaks = 4:7,
    labels = c("10,000", "100,000", "1,000,000", "10,000,000")
  ) +
  labs(
    title = "Most Earners Have Annual Earnings Below Rs. 600,000",
    subtitle = paste("Weighted median: Rs.", format(median_weighted, big.mark = ",")),
    x = "Annual earnings (rupees; logarithmic scale)",
    y = "Weighted density per log10 unit",
    caption = paste(
      "Source: PSLM 2019-20, Variant 5 (KP Urban).",
      excluded_count,
      "earner observation(s) outside Rs. 10,000-10,000,000 excluded."
    )
  ) +
  theme_minimal()

svg("figures/figure2_histogram.svg", width = 10, height = 6)
print(p2)
dev.off()

# Step 8: Question 3 - Prepare five-year age bands
age_labels <- c(
  "15-19", "20-24", "25-29", "30-34", "35-39",
  "40-44", "45-49", "50-54", "55-59", "60-64"
)

plot_earners$age_band <- cut(
  plot_earners$age,
  breaks = seq(15, 65, by = 5),
  labels = age_labels,
  right = FALSE
)

band_table <- plot_earners %>%
  group_by(age_band, .drop = FALSE) %>%
  summarise(
    n = n(),
    weighted_mean = if (sum(hhweight, na.rm = TRUE) > 0) {
      weighted.mean(earn_annual, hhweight, na.rm = TRUE)
    } else {
      NA_real_
    },
    .groups = "drop"
  )

band_table$midpoint <- seq(17, 62, by = 5)
band_table$weighted_mean <- round(band_table$weighted_mean)

print(band_table)

write.csv(
  band_table,
  "figures/age_band_R.csv",
  row.names = FALSE
)

# Report required age-band means
cat("Weighted mean, ages 25-29:",
    band_table$weighted_mean[band_table$age_band == "25-29"], "\n")

cat("Weighted mean, ages 45-49:",
    band_table$weighted_mean[band_table$age_band == "45-49"], "\n")

# Step 9: Question 3 - Redesign plot
highest <- band_table[which.max(band_table$weighted_mean), ]

p3 <- ggplot(
  plot_earners,
  aes(x = age, y = earn_annual)
) +
  geom_point(
    alpha = 0.25,
    size = 1.5,
    position = position_jitter(width = 0.4, height = 0)
  ) +
  geom_line(
    data = band_table,
    aes(x = midpoint, y = weighted_mean, group = 1),
    linewidth = 0.8,
    inherit.aes = FALSE
  ) +
  geom_point(
    data = band_table,
    aes(x = midpoint, y = weighted_mean),
    size = 3,
    inherit.aes = FALSE
  ) +
  geom_point(
    data = filter(band_table, n < 30),
    aes(x = midpoint, y = weighted_mean),
    shape = 21,
    fill = "white",
    size = 4,
    stroke = 1.2,
    inherit.aes = FALSE
  ) +
  annotate(
    "text",
    x = highest$midpoint,
    y = highest$weighted_mean,
    label = paste("Highest:", highest$age_band),
    vjust = -1,
    hjust = 0.5,
    size = 3.5
  ) +
  scale_y_log10(
    breaks = c(10000, 100000, 1000000, 10000000),
    labels = c("10,000", "100,000", "1,000,000", "10,000,000"),
    limits = c(10000, 10000000)
  ) +
  scale_x_continuous(
    breaks = seq(15, 65, by = 5),
    limits = c(15, 65)
  ) +
  labs(
    title = "Weighted Mean Earnings Peak at Ages 55-59",
    x = "Age (years)",
    y = "Annual earnings (rupees; log scale)",
    caption = paste(
      "Source: PSLM 2019-20, Variant 5 (KP Urban).",
      "Points show earners; line shows weighted age-band means.",
      "Hollow markers indicate bands with fewer than 30 earners.",
      "Weighted by household weight."
    )
  ) +
  theme_minimal()

svg("figures/figure3_age_earnings.svg", width = 10, height = 6)
print(p3)
dev.off()

# Step 10: Question 4 - Default plot
p_default <- ggplot(
  plot_earners,
  aes(x = age, y = earn_annual)
) + geom_point()

svg("figures/default.svg", width = 10, height = 6)
print(p_default)
dev.off()

cat("Assignment figures and R age-band table saved successfully.\n")
