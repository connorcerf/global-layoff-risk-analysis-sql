# Global Layoff Risk Analysis (SQL)

## Overview

This project analyzes global layoff data to evaluate **workforce risk across industries and funding stages**.

Rather than focusing solely on total layoffs, this analysis reframes the dataset around a strategic business question:

> **Which industries and funding stages show the highest layoff risk, and what actions can leaders or investors take to reduce the likelihood of catastrophic layoffs (50–100%)?**

The objective is to move beyond descriptive analytics and develop a structured, risk-oriented perspective that supports executive decision-making.

---

## Business Problem

Total layoff counts do not fully capture organizational risk.

From a leadership or investor perspective, workforce risk should be evaluated across three dimensions:

1. **Frequency** – How often layoffs occur  
2. **Severity** – The average percentage of workforce reduced  
3. **Catastrophic Events** – Workforce reductions of 50% or greater, including full shutdowns (100%)

This project builds SQL queries to quantify each of these dimensions across industries and funding stages.

---

## Tools & Techniques Used

- SQL (MySQL-style syntax)
- Data cleaning with staging tables
- Window functions (`ROW_NUMBER`, `DENSE_RANK`)
- Common Table Expressions (CTEs)
- Conditional aggregation (`CASE WHEN`)
- Rolling totals for time-based trend analysis
- Data standardization and NULL handling

---

## Data Preparation

To ensure analytical accuracy, the dataset was cleaned prior to analysis.

Key preparation steps included:

- Creating staging tables to preserve raw data integrity
- Removing duplicates using `ROW_NUMBER()`
- Standardizing inconsistent text values (company, industry, country)
- Converting date fields to proper `DATE` format
- Replacing blank values with `NULL`
- Backfilling missing industry values using self-joins
- Removing rows lacking layoff metrics

These steps ensured the final analysis was performed on structured, reliable data.

---

## Risk Analysis Framework

Layoff risk was evaluated using aggregated metrics grouped by:

- **Industry**
- **Company Stage**

For each group, the following were calculated:

- Total layoff events  
- Total employees laid off  
- Average percentage laid off  
- Number of high-severity events (≥ 50%)  
- Number of full shutdown events (100%)

This multi-dimensional framework provides a clearer view of structural volatility and organizational instability than total headcount alone.

---

## Key Findings

- Layoffs cluster during specific time periods, indicating macroeconomic and cyclical influence.
- Certain industries exhibit both high event frequency and high average layoff percentages, signaling structural volatility.
- Company stage does not eliminate risk — both early-stage and later-stage companies experience significant workforce reductions.
- Full shutdown events (100% layoffs) occur across multiple stages, demonstrating that capital raised does not guarantee operational stability.
- The United States accounts for the highest total layoff volume in the dataset.

---

## Strategic Recommendations

### 1. Monitor High-Risk Industries

Industries with elevated average layoff percentages should:

- Moderate hiring velocity during expansion cycles  
- Increase runway requirements  
- Implement scenario-based workforce planning  

---

### 2. Flag Catastrophic Workforce Reductions

Layoffs of 50% or greater should be tracked as a distinct risk category.

Organizations and investors should:

- Evaluate burn rate discipline  
- Stress test hiring assumptions  
- Prioritize sustainable scaling over aggressive expansion  

---

### 3. Do Not Rely on the Company Stage as a Safety Signal

Risk is present across all stages.

Decision-makers should focus on:

- Operational efficiency  
- Hiring discipline  
- Capital allocation strategy  

---

### 4. Use Time Trends as Early Warning Indicators

Rolling monthly totals highlight acceleration periods in workforce reductions.

Organizations can use similar tracking mechanisms internally to:

- Pause hiring during contraction periods  
- Adjust growth projections  
- Reallocate capital proactively  

---

## What This Project Demonstrates

- End-to-end data cleaning and transformation in SQL  
- A basic understanding of window functions and CTEs  
- Risk-based analytical thinking  
- Ability to translate quantitative findings into strategic recommendations  

This project reflects both technical SQL capability and business-oriented analytical reasoning.

---

## Project Background

The initial structure of this project was inspired by Alex The Analyst’s SQL World Layoffs tutorial.

The analysis was expanded beyond the guided framework by developing additional risk-based metrics, reframing the analysis around layoff frequency and severity, and incorporating strategic business recommendations which were not included in the original tutorial.
