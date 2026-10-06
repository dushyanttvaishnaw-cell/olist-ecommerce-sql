"""
Optional: turns a few of the CSVs in results/ into charts for the README.
The analysis itself is all in sql/. This is just matplotlib on top.
"""
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

plt.rcParams.update({"figure.dpi": 120, "axes.spines.top": False,
                     "axes.spines.right": False, "font.size": 10})
navy, teal, brass, rust, grey = "#14192b", "#3c6e68", "#c08a3e", "#a84a3a", "#9aa0b4"

# revenue + on time
rev = pd.read_csv("results/10_monthly_revenue.csv", parse_dates=["order_month"])
dlv = pd.read_csv("results/30_delivery_performance.csv", parse_dates=["order_month"])
fig, ax = plt.subplots(figsize=(9, 3.8))
ax.bar(rev.order_month, rev.gmv_brl / 1e6, width=20, color=teal, label="GMV (R$ M)")
ax.set_ylabel("GMV, R$ millions")
ax2 = ax.twinx()
ax2.plot(dlv.order_month, dlv.on_time_pct, color=rust, marker="o", ms=3, lw=1.6, label="on time %")
ax2.set_ylim(75, 100)
ax2.set_ylabel("on time %", color=rust)
ax2.spines["top"].set_visible(False)
ax.set_title("Monthly GMV vs on time delivery, Jan 2017 to Aug 2018", loc="left")
fig.tight_layout(); fig.savefig("charts/revenue_vs_on_time.png"); plt.close(fig)

# cohort heatmap
c = pd.read_csv("results/20_cohort_retention.csv", parse_dates=["cohort"])
m = c.set_index(c.cohort.dt.strftime("%Y-%m"))[["m1", "m2", "m3", "m4", "m5", "m6"]]
fig, ax = plt.subplots(figsize=(7, 5.2))
im = ax.imshow(m.values, cmap="Blues", aspect="auto", vmin=0, vmax=0.8)
ax.set_xticks(range(6), [f"month {i}" for i in range(1, 7)])
ax.set_yticks(range(len(m)), [f"{i}  (n={n:,})" for i, n in zip(m.index, c.cohort_size)])
for i in range(m.shape[0]):
    for j in range(m.shape[1]):
        ax.text(j, i, f"{m.values[i, j]:.2f}", ha="center", va="center", fontsize=8,
                color="white" if m.values[i, j] > 0.5 else navy)
ax.set_title("% of each monthly cohort that ordered again, by month", loc="left")
for s in ax.spines.values():
    s.set_visible(False)
fig.tight_layout(); fig.savefig("charts/cohort_retention.png"); plt.close(fig)

# late delivery vs reviews
r = pd.read_csv("results/31_late_delivery_vs_reviews.csv")
r["label"] = r.delivery_bucket.str.slice(3)
fig, ax = plt.subplots(figsize=(8, 3.4))
cols = [teal, teal, brass, rust, rust]
b = ax.bar(r.label, r.avg_review, color=cols, width=0.6)
for bar, v, o in zip(b, r.avg_review, r.one_star_pct):
    ax.text(bar.get_x() + bar.get_width() / 2, v + 0.05, f"{v:.2f}\n({o:.0f}% 1 star)",
            ha="center", va="bottom", fontsize=8.5)
ax.set_ylim(0, 5.2)
ax.set_ylabel("avg review score")
ax.set_title("Review score by delivery vs the promised date", loc="left")
fig.tight_layout(); fig.savefig("charts/late_vs_reviews.png"); plt.close(fig)
print("charts saved")
