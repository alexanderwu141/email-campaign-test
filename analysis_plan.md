# Analysis plan

## 1. Question
An online apparel retailer wants to know whether an email campaign is worth sending. Specifically, they are interested in whether past customers who receive one of two different promotional emails would return and buy more in the next two weeks.

## 2. Groups
64,000 customers who bought in the past 12 months are randomly split into three groups:

```
Treatment A (men's email):   a promotional email featuring men's clothing
Treatment B (women's email): a promotional email featuring women's clothing
Control (no email):          no promotional email
```

Random assignment makes the groups alike in everything except the email, so differences in outcomes can be attributed to the email.

## 3. Primary metric
**Average spend per customer**, including those who spent $0, will be used to measure how effective each email campaign is. Most customers spend $0, so spend is skewed and noisy; section 5 handles this.

## 4. Secondary metrics
- **Visit rate:** did the email bring customers back?
- **Conversion rate:** did more customers buy?
- **Spend among buyers:** did buyers spend more per order?

Together they show whether extra revenue came from more buyers or bigger orders.

## 5. Comparisons and methods

Each metric is compared three ways:
- Men's email vs no email: did the men's email work?
- Women's email vs no email: did the women's email work?
- Men's email vs women's email: which worked better?

Results will be reported as a difference with a 95% confidence interval, e.g. "average spend +$0.40 per customer (95% CI +$0.15 to +$0.65)". If the whole interval is above zero, the email very likely helped.

Statistical tests used:

- Visit and conversion are yes/no, so they're compared as percentages with a two-proportion z-test.
- Spend is mostly $0 with a few large values. It is compared with a Welch t-test, which gives the p-value and confidence interval; a bootstrap confidence interval (2,000 resamples) checks that the result holds despite the skew.
- A result counts as significant at p < 0.05 (two-sided: the email could help or hurt).

**Avoiding false positives.** Because many tests are run, some will look significant by chance. So average spend (the primary metric) will decide whether an email worked, and the p-values of all other tests will be adjusted with the Holm method.

## 6. Checks before analysing, and subgroups

- No missing values in any column.
- Group sizes are consistent with an equal three-way split (chi-square test). If p < 0.01,
  the random assignment may be broken: stop and investigate.
- The groups looked alike before the emails (past spend, recency, new customers, channel, area). Large differences would also mean stop.

**Subgroups.** For average spend only, check whether the emails worked differently for:
- past men's buyers vs not
- past women's buyers vs not
- recency: last purchase 1–3, 4–6 or 7–12 months ago
- past big spenders: spent above the median in the past year vs the rest

**Matching.** Within past men's buyers, and separately within past women's buyers, compare the men's email with the women's email: does an email work better when it matches what the customer already buys?

## 7. ROI assumptions
- **Cost per email: $0.01.** Bulk sending alone costs about $0.001–0.0015 per email at scale; $0.01 also allows for design and staff time.
- **Gross margin: 40%.** Public apparel companies range from about 35% (apparel retailers) to about 57% (apparel brands); 40% is a conservative middle for a retailer, before returns.

These are assumptions, so the ROI model also reports the break-even cost per email and results across costs of $0.001–$0.10 and margins of 30–60%.

## 8. Decision rule
- **Send to everyone** if the email's spend effect has a 95% CI above zero and its net value per customer is positive at the assumed cost and margin. If both emails qualify, pick the one with higher net value.
- **Send to a subgroup only** if the overall effect doesn't pay but a planned subgroup clearly does.
- **Don't send** if neither email clearly raises spend or covers its cost.