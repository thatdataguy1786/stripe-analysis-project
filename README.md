# Stripe Analysis Project
**Author:** Kushraj Bhatia  
**Project Type:** Data Analysis & Business Intelligence  
**Tools:** SQL (PostgreSQL), Python (pandas)

---

## 📋 Executive Summary

Developed a data-driven targeting framework to identify existing Stripe merchants most likely to adopt subscription products, with **$5.4M-7.2M projected annual revenue impact**. Analyzed 23,422 merchants and 1.57M payment transactions to build a sophisticated 5-dimensional scoring system that successfully identified 860 "perfect target" merchants with characteristics mirroring existing subscription winners.

**Key Achievement:** Created an actionable, prioritized merchant list that enables focused sales campaigns with expected 18-20% conversion rates, validated against existing subscription user behavior patterns.

---

## 🎯 Business Problem

**Objective:** Increase subscription product adoption among existing Stripe merchants who are manually processing recurring payments through Checkout and Payment Links.

**Challenge:** Among 23,000+ merchants, identify which ones:
- Would benefit most from automation through subscriptions
- Are most likely to convert based on behavioral patterns
- Represent the highest revenue opportunity

**Stakeholder:** Head of Product (preparing for sales/marketing campaign)

---

## 📊 Data Overview

### Datasets
1. **Merchants Table** (23,627 records)
   - Merchant attributes: industry, country, business_size, first_charge_date
   - Cleaned to 23,422 valid merchants (removed 205 with invalid IDs/dates)

2. **Payments Table** (1,577,887 records)
   - Daily transaction volume by product (subscriptions, checkout, payment_link)
   - Date range: May 2041 - June 2042 (13 months)
   - Cleaned to 1,566,560 valid records (removed 11,327 with invalid merchant IDs)

### Critical Data Insights
- **Product volumes are NOT mutually exclusive** - merchants can use multiple products for single transactions
- **77.7% of records** show `total_volume ≠ sum(product volumes)`, confirming overlap
- **No null values** after cleaning
- **Volume measured in cents** (converted to dollars for analysis)

---

## 🔬 Methodology

### Three-Stage Analytical Framework

#### **Stage 1: Understand Subscription Winners**
Analyzed existing subscription users to identify success patterns:

**Key Findings:**
- **Top Industry:** US Software (81 merchants, $195K/month avg subscription revenue)
- **High Reliance:** 84-90% of revenue from subscriptions once adopted
- **Business Size:** Small businesses dominate successful adoption (86-92% subscription reliance)
- **Geographic Concentration:** US, GB, Japan lead adoption
- **Critical Insight:** Merchants using BOTH Checkout (73%) AND Subscriptions (84%) validate gradual migration strategy

**Tenure Matters:**
- Mature merchants (12+ months): $63,937/month subscription revenue
- New merchants (≤6 months): $11,784/month subscription revenue
- **5.4X difference** validates targeting established merchants only

#### **Stage 2: Define "Subscription-Ready" Criteria**
Created PostgreSQL view (`recurring_merchants`) filtering for:

1. ✅ **No Current Subscription Usage** (`subscription_volume = 0`)
2. ✅ **Recurring Transaction Behavior** (≤10 days average between transactions)
3. ✅ **Established Pattern** (>10 total transactions)
4. ✅ **Sufficient Scale** (meaningful transaction volume)

**Rationale:** If merchants are manually processing recurring payments, they're ideal subscription candidates.

**Result:** **7,819 qualifying merchants**

#### **Stage 3: Build Data-Driven Scoring System**

**Five-Dimensional Scoring Framework:**

| Dimension | 3 Points | 2 Points | 1 Point |
|-----------|----------|----------|---------|
| **Volume Score** | ≥$30K/month | ≥$8.75K/month | <$8.75K/month |
| **Checkout Score** | ≥$20K/month | ≥$6K/month | <$6K/month |
| **Engagement Score** | ≥12 months tenure | ≥6 months | <6 months |
| **Frequency Score** | ≤5 days between transactions | ≤7 days | ≤10 days |
| **Transaction Score** | ≥25 transactions/month | ≥15/month | <15/month |

**Thresholds Determined by Percentile Analysis:**
- P90 (top 10%): 3 points
- P75 (top 25%): 2 points
- Below P75: 1 point

**Segmentation by Total Score:**
- **Perfect Targets (12-15 points):** 860 merchants (11%) - immediate focus
- **Excellent Targets (9-11 points):** 3,439 merchants (44%) - secondary wave
- **Good Targets (<9 points):** 3,520 merchants (45%) - long-tail opportunity

---

## 🎯 Key Findings & Results

### Target Universe Breakdown

**Top 5 Segments (Perfect Targets):**
1. **US Software, Small:** 37 targets, $32,301/month avg volume
2. **US Business Services, Small:** 35 targets, $24,664/month avg
3. **GB Food & Drink, Small:** 24 targets, $13,573/month avg
4. **US Others, Small:** 23 targets, $22,329/month avg
5. **US Education, Small:** 20 targets, $18,366/month avg

**Pattern Identified:** US small businesses dominate top segments

### Validation: Do Our Targets Look Like Subscription Winners?

**Comparison Analysis:**

**Business Services Segment:**
- Existing subscription users: $79,873/month avg, 13.56 months tenure
- Our perfect targets: $200,700/month avg, 13.70 months tenure ✅

**Software Segment:**
- Existing subscription users: $408,196/month avg, 13.20 months tenure
- Our perfect targets: $139,464/month avg, 13.81 months tenure ✅

**Conclusion:** Our non-subscribed targets have the SAME maturity and usage patterns as successful subscription merchants, validating our methodology.

---

## 💰 Business Impact & Recommendations

### Phased Rollout Strategy

**Phase 1: Pilot (Top 72 Merchants)**
- **Target:** US Software (37) + US Business Services (35)
- **Expected Conversion:** 20% (14-15 new adopters)
- **Projected New MRR:** $210K-225K/month
- **Annual Run Rate:** **$2.52M-2.7M**

**Phase 2: Scale (Next 128 Merchants)**
- **Target:** Expand to top 200 perfect targets across all industries/geographies
- **Expected Outcomes:** Additional 25-30 conversions
- **Cumulative New MRR:** $450K-600K/month
- **Annual Run Rate:** **$5.4M-7.2M**

### Success Metrics Proposal

**Metric 1: Subscription Adoption Rate**
- **Definition:** % of targeted merchants who activate subscriptions within 90 days
- **Target:** 18-20% adoption
- **Red Flag:** <10% (re-evaluate targeting)

**Metric 2: Average Subscription Revenue per Adopter**
- **30-day:** ≥$3,000 (ramp-up phase)
- **60-day:** ≥$7,000 (pattern establishment)
- **90-day:** ≥$10,000 (sustainable revenue)

**Metric 3: Subscription Penetration Rate by Segment**
- Track quarterly growth in subscription adoption within each industry/country/size segment
- Identify fastest-converting segments for future targeting refinement

---

## 🔮 Next Steps & Future Enhancements

### Short-Term (1-4 weeks)
1. Industry-specific messaging & value propositions
2. A/B test outreach methods (email vs sales call vs webinar)

### Medium-Term (1-3 months)
3. Cohort analysis by merchant signup date
4. Churn risk modeling for existing subscription users
5. Product usage pattern deep dive (optimal Checkout→Subscription migration timeline)

### Long-Term (3-6 months)
6. Economic value analysis (CLV comparison: subscription vs non-subscription merchants)
7. Attribution modeling post-launch

---

## 🛠️ Technical Implementation

### Tools & Technologies
- **SQL (PostgreSQL):** Data cleaning, feature engineering, scoring system, merchant targeting
- **Python (pandas):** Data validation, exploratory analysis, quality checks
- **Power BI:** Data visualization and pattern exploration
- **Git:** Version control and project documentation

### Code Structure
```
stripe-analysis-project/
├── load_data_to_postgres/
│   ├── load_data_to_postgres.py       # Initial data loading
│   └── load_payments_to_postgres.py   # Payment data pipeline
├── cleaning_analysis_all_tables/
│   ├── merchants_cleaning_and_analysis.py  # Merchant data cleaning
│   └── payments_cleaning_and_analysis.py   # Payment data cleaning
├── tables_creation_sql/
│   └── db_creation.sql                # Database schema setup
├── views/
│   └── creating_recurring_merchants_views.sql  # Subscription-ready merchants view
├── merchant_x_payments_final_analysis.sql  # Final scoring & targeting query
├── basic_table_exploration.sql        # Initial data exploration
├── Target_200_merchants_final_list.xlsx    # Final merchant targets
└── README.md                          # Project documentation
```

### Key SQL Techniques Used
- **Window Functions:** For calculating rolling averages, transaction frequency
- **CTEs (Common Table Expressions):** For building complex scoring logic
- **Views:** For reusable merchant segmentation
- **Percentile Analysis:** For data-driven threshold selection
- **Join Operations:** Combining merchant attributes with payment behavior

---

## 📈 Skills Demonstrated

### Technical Skills
- ✅ **Advanced SQL:** Complex queries, window functions, CTEs, views
- ✅ **Python Data Analysis:** pandas, data cleaning, validation
- ✅ **Data Quality Assessment:** Handling invalid IDs, date inconsistencies, volume mismatches
- ✅ **Feature Engineering:** Creating behavioral and firmographic features
- ✅ **Statistical Analysis:** Percentile-based thresholds, validation testing

### Business & Analytical Skills
- ✅ **Problem Decomposition:** Breaking complex business problems into analytical steps
- ✅ **Stakeholder Communication:** Translating technical findings into business recommendations
- ✅ **Framework Development:** Building reusable scoring methodologies
- ✅ **Strategic Thinking:** Phased rollout strategy with clear success metrics
- ✅ **Data Storytelling:** Comprehensive presentation with actionable insights

---

## 🚨 Assumptions & Limitations

### Data Assumptions
- Products are NOT mutually exclusive (per documentation)
- Future dates (2041-2042) represent synthetic data for analysis purposes
- 13-month observation window may not capture full annual seasonality

### Methodology Assumptions
- Recurring behavior (≤10 days) indicates subscription need
- 20% conversion rate based on B2B SaaS industry benchmarks
- Subscription winners' profiles remain stable over time

### Limitations
- Cannot measure "natural" adoption (merchants who would convert without outreach)
- No historical churn data to refine targeting
- No qualitative merchant feedback on subscription barriers

---

## 📫 Contact

**Kushraj Bhatia**  
[LinkedIn](https://www.linkedin.com/in/kushrajbhatia) | [GitHub](https://github.com/thatdataguy1786)

---

## 📄 Project Files

- **Presentation:** `Stripe_Project_Analysis.pdf` - Complete slide deck with visualizations
- **Final Query:** `merchant_x_payments_final_analysis.sql` - Production-ready targeting logic
- **Target List:** `Target_200_merchants_final_list.xlsx` - Prioritized merchant list for campaign
- **Documentation:** This README with full methodology and findings

---

*This project demonstrates end-to-end data analysis capabilities: from data cleaning and quality assessment through feature engineering, analytical framework development, validation, and actionable business recommendations with measurable success metrics.*
