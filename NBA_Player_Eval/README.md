# 🏀 NBA Player Evaluation

**NBA_Player_Evaluation.ipynb** is a self-directed analytics project developed as part of graduate coursework. The analysis uses data from `nba_salaries.csv` (sourced from Kaggle) to explore strategies for building high-performing, balanced NBA teams under salary cap constraints.

---

## ❓ Project Question

> **How can NBA teams target high-performing players with relatively low salaries to build a winning, balanced roster?**

NBA teams operate under a salary cap, meaning they can't spend unlimited amounts on player salaries. Spending too much on a single star player can result in a lack of depth or imbalance across the five positions. Using statistical modeling, this project explores how to identify **undervalued players** — those who significantly **outperform their salaries**.

---

## ⚙️ Methods and Models

This notebook applies three distinct modeling approaches:

### 1. 📉 Regression (Salary Prediction)
- **Basic linear regression** using performance statistics to predict salary  
- **Refined regression** with:
  - Outliers removed
  - A reduced set of relevant features  
- **Log-transformed regression** to handle skewed salary distribution

### 2. 🧪 Classification (High vs. Low Salary)
- Define salary categories:
  - **High salary**: > 75th percentile
  - **Low salary**: ≤ 25th percentile
- Train a classification model using **XGBoost**
- Identify **false positives**: players predicted as high-salary based on performance but paid less, potential undervalued assets

### 3. 📈 Linear Interpolation
- Assign an **expected salary** based on normalized performance metrics
- Compute the **difference** between actual and interpolated salaries
- Flag **top overperformers** who offer high value for their cost

---

## 📁 Files Included
- `NBA_Player_Evaluation.ipynb`: Main analysis notebook
- `nba_salaries.csv`: Dataset (sourced from Kaggle)


---
Created by: Molly Szeman
Last updated: June 2025