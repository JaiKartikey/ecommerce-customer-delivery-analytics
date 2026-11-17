"""Make the 3 story charts for the Olist project. Run: python charts.py <data_dir>"""
import sys, duckdb, matplotlib; matplotlib.use("Agg"); import matplotlib.pyplot as plt
D = sys.argv[1] if len(sys.argv) > 1 else "data"
con = duckdb.connect()
for t, f in [("orders","olist_orders_dataset"),("items","olist_order_items_dataset"),("reviews","olist_order_reviews_dataset"),("customers","olist_customers_dataset")]:
    con.execute(f"CREATE TABLE {t} AS SELECT * FROM read_csv_auto('{D}/{f}.csv')")
def q(name): return con.execute(open(f"sql/{name}").read().split(';')[0] if False else open(f"sql/{name}").read()).df()
plt.rcParams.update({"figure.dpi": 150, "axes.spines.top": False, "axes.spines.right": False})
m = q("01_monthly_revenue.sql")
fig, ax = plt.subplots(figsize=(8, 3.5)); ax.plot(m.month, m.revenue / 1e6, color="#2f6db5", lw=2)
ax.set_title("Monthly revenue, delivered orders (BRL millions)"); ax.annotate("Black Friday, Nov 2017", (m.month[10], m.revenue[10]/1e6), xytext=(-140, 5), textcoords="offset points")
fig.tight_layout(); fig.savefig("chart1_monthly_revenue.png")
d = q("04_delivery_vs_reviews.sql")
fig, ax = plt.subplots(figsize=(6, 3.5)); b = ax.bar(d.bucket.str[3:], d.avg_review, color=["#2f6db5", "#e8a33d", "#c8442f"])
ax.bar_label(b, fmt="%.2f"); ax.set_ylim(0, 5); ax.set_title("Average review score by delivery delay")
fig.tight_layout(); fig.savefig("chart2_delay_vs_rating.png")
s = q("05_late_by_state.sql").sort_values("late_pct")
fig, ax = plt.subplots(figsize=(6, 4)); ax.barh(s.state, s.late_pct, color=["#c8442f" if x > 12 else "#9bb4d6" for x in s.late_pct])
ax.set_title("Late-delivery rate by state, % (states with 1,000+ orders)"); fig.tight_layout(); fig.savefig("chart3_late_by_state.png")
print("saved 3 charts")
