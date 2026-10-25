```python
# ECO346 Assignment 1 - Question 5
# Python verification of weighted mean earnings by age band
# Variant 5: KP Urban

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# Step 1: Load the two CSV files
person = pd.read_csv("../data/pslm_person_subset.csv")
household = pd.read_csv("../data/pslm_hh_subset.csv")

# Step 2: Merge person and household data using hhid
data = person.merge(
    household[["hhid", "hhweight", "prov_code", "urban_rural"]],
    on="hhid",
    how="left"
)

# Step 3: Select Variant 5 - KP Urban
sample = data[
    (data["prov_code"] == 1) &
    (data["urban_rural"] == 2)
].copy()

# Step 4: Select earners aged 15-64
earners = sample[
    (sample["age"] >= 15) &
    (sample["age"] <= 64) &
    (sample["earn_annual"] > 0)
].copy()

# Step 5: Apply the same income and weight filters as R
earners = earners[
    (earners["earn_annual"] >= 10000) &
    (earners["earn_annual"] <= 10000000) &
    (earners["hhweight"].notna()) &
    (earners["hhweight"] > 0)
].copy()

# Step 6: Create five-year age bands
edges = [15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65]

labels = [
    "15-19", "20-24", "25-29", "30-34", "35-39",
    "40-44", "45-49", "50-54", "55-59", "60-64"
]

earners["age_band"] = pd.cut(
    earners["age"],
    bins=edges,
    labels=labels,
    right=False
)

# Step 7: Calculate weighted mean earnings
def calculate_weighted_mean(group):
    return np.average(
        group["earn_annual"],
        weights=group["hhweight"]
    )

band_table = (
    earners.groupby("age_band", observed=False)
    .apply(
        lambda group: pd.Series({
            "n": len(group),
            "weighted_mean": calculate_weighted_mean(group)
            if len(group) > 0 else np.nan
        }),
        include_groups=False
    )
    .reset_index()
)

# Display the results
band_table["weighted_mean"] = band_table["weighted_mean"].round(0)

print("Weighted mean annual earnings by age band:")
print(band_table.to_string(index=False))

# Save the age-band table
band_table.to_csv(
    "age_band_python.csv",
    index=False
)

# Step 8: Prepare data for the graph
plot_table = band_table.copy()
plot_table["midpoint"] = np.arange(17, 63, 5)

fig, ax = plt.subplots(figsize=(10, 6))

# Individual earners with horizontal jitter
rng = np.random.default_rng(42)

jittered_age = earners["age"].to_numpy() + rng.uniform(
    -0.4, 0.4, size=len(earners)
)

ax.scatter(
    jittered_age,
    earners["earn_annual"],
    alpha=0.25,
    s=18
)

# Weighted mean line and markers
ax.plot(
    plot_table["midpoint"],
    plot_table["weighted_mean"],
    marker="o"
)

# Hollow markers for bands with fewer than 30 earners
small = plot_table["n"] < 30

ax.scatter(
    plot_table.loc[small, "midpoint"],
    plot_table.loc[small, "weighted_mean"],
    facecolors="none",
    edgecolors="black",
    s=90,
    label="Fewer than 30 observations"
)

# Annotate the age band with the highest weighted mean
highest = plot_table["weighted_mean"].idxmax()

ax.annotate(
    "Highest: 55-59",
    (
        plot_table.loc[highest, "midpoint"],
        plot_table.loc[highest, "weighted_mean"]
    ),
    xytext=(8, 10),
    textcoords="offset points"
)

# Logarithmic earnings axis
ax.set_yscale("log")
ax.set_ylim(10000, 10000000)
ax.set_yticks([10000, 100000, 1000000, 10000000])
ax.set_yticklabels(["10,000", "100,000", "1,000,000", "10,000,000"])

ax.set_xlim(15, 65)
ax.set_xticks(np.arange(15, 66, 5))

ax.set_title("Weighted Mean Earnings Peak at Ages 55-59")
ax.set_xlabel("Age (years)")
ax.set_ylabel("Annual earnings (rupees, log scale)")
ax.legend()

fig.text(
    0.01, 0.01,
    "Source: PSLM 2019-20, Variant 5 (KP Urban). "
    "Points show earners; line shows age-band weighted means. "
    "Hollow markers indicate bands with fewer than 30 observations. "
    "Weighted by household weight.",
    fontsize=8
)

fig.tight_layout(rect=[0, 0.06, 1, 1])

# Step 9: Save the SVG graph
fig.savefig(
    "../figures/figure3_age_earnings_python.svg",
    format="svg"
)

plt.show()

print("Python verification and graph completed.")
print("Graph saved in the figures folder.")
```

