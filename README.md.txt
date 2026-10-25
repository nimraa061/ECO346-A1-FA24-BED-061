# ECO346 Assignment 1

## Student Information
- Registration Number: FA24-BEd-061
- Variant: 5
- Sample: KP Urban

## Question 2: Annual Earnings Distribution

The sample contains 678 earners. The unweighted median annual income is Rs. 240,000, and the weighted median is also Rs. 240,000. The weighted 10th percentile is Rs. 108,000, while the weighted 90th percentile is Rs. 588,000. The P90/P10 ratio is 5.44. One observation with annual earnings of Rs. 5,000 falls outside the plotting range and is excluded from the histogram.

## Question 3: Earnings by Age

The weighted mean annual earnings for ages 25–29 are Rs. 289,679, compared with Rs. 361,264 for ages 45–49. The highest weighted mean is Rs. 471,159 for ages 55–59. The mean falls to Rs. 203,724 for ages 60–64, but this band contains only 15 earners, so the estimate should be interpreted cautiously. These results show an association between age and earnings, not proof that age causes income to change.

## Figures
- Question 2: `figures/figure2_histogram.svg`
- Question 3: `figures/figure3_age_earnings.svg`

## Age-Band Summary

| Age band | Number of earners | Weighted mean annual earnings (Rs.) |
|---|---:|---:|
| 15–19 | 35 | 152,102 |
| 20–24 | 82 | 203,196 |
| 25–29 | 89 | 289,679 |
| 30–34 | 86 | 303,177 |
| 35–39 | 118 | 364,289 |
| 40–44 | 104 | 377,476 |
| 45–49 | 65 | 361,264 |
| 50–54 | 49 | 451,343 |
| 55–59 | 34 | 471,159 |
| 60–64 | 15 | 203,724 |



## Question 4: Default Plot vs Redesign

The default scatter plot is difficult to interpret because many observations overlap and the large range of earnings makes lower incomes harder to distinguish. The redesign uses a logarithmic y-axis to show low and high earnings more clearly, transparency to reduce overplotting, and a line connecting weighted mean earnings across age bands to reveal the overall pattern. Larger markers distinguish age-band averages, while hollow markers identify groups with fewer than 30 observations. These changes improve readability and direct attention to the main relationship. However, the default plot shows individual observations without summarising them, a detail that the redesigned plot makes less prominent.

## Question 4 Figure Files
- Default plot: `figures/default.svg`
- Redesigned plot: `figures/figure3_age_earnings.svg`


## Question 5: Python Verification

The age-band weighted means were independently recalculated in Python and matched the R results for all ten age bands. For ages 25–29, the weighted mean annual earnings are Rs. 289,679 in both R and Python.

The initial Python calculation for ages 55–59 differed from R because the income-range exclusion was not applied. After applying the same Rs. 10,000–10,000,000 income limits and positive, non-missing household weights, the count and weighted mean matched R: 34 earners and Rs. 471,159.

## Question 5 Figure
- Python-redrawn age–earnings figure: `figures/figure3_age_earnings_python.svg`