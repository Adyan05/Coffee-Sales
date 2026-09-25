# Coffee Sales Analysis | Excel, PostgreSQL & Power BI

## Project Overview

This portfolio project analyses coffee sales transactions from January 2019 to August 2022. The goal is to turn raw order, customer and product data into clear business information about revenue, demand, customer behaviour and sales performance.

The project follows a practical analyst workflow: prepare the data in Excel, load structured tables into PostgreSQL, answer business questions with SQL, build reusable measures in Power BI and present the results through an interactive dashboard.

## Business Objectives

The analysis was designed to answer questions that a sales manager or business analyst might ask:

- How are revenue, order volume and units sold changing over time?
- Which coffee types, roast types and package sizes generate the most revenue?
- Which countries contribute the most sales?
- Who are the highest-value and repeat customers?
- How do loyalty-card customers compare with non-loyalty customers?
- Which products perform best within different markets?
- Are there monthly patterns that may help with planning and customer retention?

## Dataset

The analysis uses three related business tables:

| Table | Description | Example fields |
| --- | --- | --- |
| `orders` | Transaction-level sales data | Order ID, order date, customer ID, product ID, quantity, unit price and sales |
| `customers` | Customer and location information | Customer name, email, phone number, city, country and loyalty-card status |
| `products` | Product and pricing information | Coffee type, roast type, size, unit price, price per 100g and profit |

The prepared dataset contains:

- 1,000 sales rows
- 957 distinct orders
- 1,000 registered customers, including 913 purchasing customers
- 48 products
- Sales from 2 January 2019 to 19 August 2022

August 2022 is a partial month, so it should not be compared directly with complete months without accounting for the shorter reporting period. The source data does not specify a currency, so monetary values are described as **source currency** throughout the project.

## Tools & Technologies

| Tool | Use in the project |
| --- | --- |
| Microsoft Excel | Data enrichment, validation, formulas, tables, PivotTables and exploratory analysis |
| PostgreSQL | Relational tables and progressive business analysis using SQL |
| Power Query | Importing the PostgreSQL tables into the Power BI model |
| Power BI | Data modelling, DAX measures, interactive analysis and dashboard development |
| DAX | Reusable KPIs, time comparisons and percentage measures |

## Data Preparation

The preparation process included:

- Separating the source into orders, customers and products tables.
- Checking identifiers, dates, quantities, prices and sales fields for appropriate data types.
- Enriching the orders table with customer and product attributes using lookup formulas.
- Using `XLOOKUP` and `INDEX`/`MATCH` to retrieve customer and product details.
- Calculating sales as quantity multiplied by unit price.
- Converting abbreviated coffee and roast codes into readable category names.
- Checking blank contact fields with `TRIM`, `NULLIF` and `COALESCE` in SQL.
- Loading the PostgreSQL tables into Power BI using Power Query import mode.
- Creating one-to-many relationships from Customers, Products and Calendar to Orders.
- Adding a dedicated Calendar table for monthly analysis and time-intelligence measures.
- Creating measures for business metrics instead of relying on implicit aggregation of raw columns.

## Excel Analysis

The Excel workbook demonstrates how a transaction table can be enriched and summarised before dashboard development. Techniques used include:

- A structured Orders table
- `XLOOKUP` for customer name, email, country and loyalty status
- `INDEX`/`MATCH` for coffee type, roast type, size and unit price
- `IF` expressions for readable coffee and roast names
- Calculated sales fields
- PivotTables for summarising total sales
- Exploratory summaries by date, country, product and customer

## SQL Analysis

The SQL exercises progress from data validation and filtering to analyst-level business analysis. They cover:

- Filtering, sorting, pattern matching and null handling
- Aggregated KPIs such as revenue, units, customers and average order value
- Joins between orders, customers and products
- Customer and product profitability analysis
- Common table expressions and subqueries
- Ranking and top-N analysis with window functions
- Revenue contribution, running totals and moving averages
- Month-over-month and year-over-year comparisons
- Repeat-purchase and retention analysis

The SQL files are organised by learning stage so the reasoning behind each technique is visible alongside the query.

## Power BI Dashboard

The Power BI report contains two pages:

### Sales Overview

- Total Revenue
- Total Orders
- Units Sold
- Purchasing Customers
- Average Order Value
- Monthly revenue trend
- Revenue by country
- Revenue by coffee type
- Dropdown slicers for year, country and coffee type

### Monthly Detail

- Monthly revenue, orders, units and purchasing customers
- Average Order Value by month
- Month-over-month revenue growth
- Year-over-year revenue growth
- Slicers synchronised with the overview page

The report uses consistent KPI cards, icons, spacing, typography and colour formatting. Tooltips provide additional context without crowding the main page. Growth results are left blank when a valid comparison is unavailable, including the partial August 2022 period.

## DAX Measures

DAX was used to create reusable measures that respond to report filters and slicers.

```DAX
Total Revenue =
SUM('public orders'[sales])
```

```DAX
Total Orders =
DISTINCTCOUNT('public orders'[orderid])
```

```DAX
Units Sold =
SUM('public orders'[quantity])
```

```DAX
Purchasing Customers =
DISTINCTCOUNT('public orders'[customerid])
```

```DAX
Average Order Value =
DIVIDE([Total Revenue], [Total Orders])
```

```DAX
Revenue Share =
DIVIDE(
    [Total Revenue],
    CALCULATE(
        [Total Revenue],
        ALLSELECTED('public customers'[country]),
        ALLSELECTED('public products'[Coffee Type Name])
    )
)
```

`DISTINCTCOUNT` is used for orders because one Order ID can appear on more than one sales line. `DIVIDE` is used instead of the `/` operator so the measure handles zero or blank denominators safely.

## Key Insights

The following results were calculated from the project data:

| Finding | Result |
| --- | --- |
| Total revenue | 45,135.35 in source currency |
| Units sold | 3,551 |
| Distinct orders | 957 |
| Purchasing customers | 913 |
| Average Order Value | 47.16 |
| Largest country by revenue | United States: 35,639.73, approximately 79% of total revenue |
| Highest-revenue coffee type | Excelsa: 12,306.71 |
| Highest-revenue roast type | Light roast: 17,354.87 |
| Highest-revenue package size | 2.5 size: 23,786.12 |
| Highest-revenue month | February 2020: 1,798.40 |
| Highest-revenue customer | Allis Wilmore: 317.08 |
| Highest-revenue product | Arabica, Light roast, 2.5 size: 2,561.59 |

Additional observations:

- The United States is the dominant market, which creates both a strong core market and a geographic concentration risk.
- Revenue is relatively balanced across Excelsa, Liberica and Arabica, while Robusta contributes less revenue in this dataset.
- Only 25 purchasing customers placed more than one distinct order, highlighting an opportunity to improve repeat purchasing and retention.
- Loyalty and non-loyalty customers average approximately 1.05 orders per purchasing customer. In this sample, loyalty-card customers do not produce a higher Average Order Value, so the programme could be reviewed for stronger repeat-purchase incentives.
- The 2.5-size product format contributes more revenue than the other sizes and should be considered in inventory and promotion planning.

## Dashboard Preview

Add a dashboard screenshot to `images/coffee-sales-dashboard.png`, then use:

```markdown
![Coffee Sales Dashboard](images/coffee-sales-dashboard.png)
```

## Repository Structure

```text
Coffee-Sales/
├── Coffee Sales.pbix          # Interactive Power BI report
├── CoffeeData.xlsx            # Prepared Excel dataset and analysis
├── orders.csv                 # Sales-line source data
├── customers.csv              # Customer source data
├── customers_clean.csv        # Cleaned customer data
├── products.csv               # Product source data
├── TableSQL.sql               # PostgreSQL table definitions
├── SimpleSummary.sql          # SQL fundamentals and data checks
├── AggregationKPI.sql         # Aggregations and business KPIs
├── MultitableAnalysis.sql     # Join-based analysis
├── AdvancedAnalysis.sql       # CTEs, subqueries and advanced analysis
├── QuestionSQL.sql            # Business-question reference
└── README.md
```

## How to Use the Project

1. Clone the repository:

   ```bash
   git clone https://github.com/Adyan05/Coffee-Sales.git
   ```

2. Open `CoffeeData.xlsx` in Microsoft Excel to review the prepared dataset, lookup formulas and PivotTable analysis.
3. Open the SQL files in PostgreSQL or another compatible SQL editor. Run `TableSQL.sql` before loading the CSV files and executing the analysis scripts.
4. Open `Coffee Sales.pbix` in Power BI Desktop.
5. Use the Year, Country and Coffee Type slicers to explore how KPIs and charts change under different selections.

The PBIX contains imported data for viewing. Refreshing the model requires access to a PostgreSQL database named `coffeesales` with the required tables.

## Skills Demonstrated

- Data cleaning and validation
- Data transformation and enrichment
- Relational data modelling
- Exploratory data analysis
- Excel tables, formulas and PivotTables
- PostgreSQL and analytical SQL
- Power Query
- DAX measure development
- Time-series analysis
- KPI design
- Interactive dashboard development
- Business-question framing
- Communicating findings and recommendations

## Future Improvements

- Add a dashboard screenshot and short report demonstration GIF to the repository.
- Add customer segmentation using recency, frequency and monetary value.
- Extend profit and margin analysis after confirming the business definition of the product profit field.
- Add drill-through pages for individual customers and products.
- Introduce retention cohorts to monitor repeat purchasing over time.
- Configure a documented PostgreSQL refresh process for Power BI.
- Add data-quality checks for duplicate identifiers, missing contact information and unexpected values.

## Author

**Adyan**

- GitHub: [Adyan05](https://github.com/Adyan05)
- LinkedIn: [Add LinkedIn profile](https://www.linkedin.com/in/your-profile/)
