# Digital_foundry_demand_forcasting
In tune with conventional big data and data science practitioners’ line of thought, currently causal analysis was the only approach considered for our demand forecasting effort which was applicable across the product portfolio. Experience dictates that not all data are same. Each group of data has different data patterns based on how they were sold and supported over the product life cycle. One-methodology-fits-all is very pleasing from an implementation of view. On a practical ground, one must consider solutions for varying needs of different product types in our product portfolio like  new products both evolutionary and revolutionary, niche products, high growth products and more.   With this backdrop, we have evolved a solution which segments the product portfolio into quadrants and then match a series of algorithms for each quadrant instead of one methodology for all. And technology stack would be simulated/mocked data(Hadoop Ecosystem) > AzureML with R/Python > Zeppelin. 

<p align="center">
<img src="https://github.com/kumarchinnakali/digital-foundry-demand-forcasting/blob/master/Images/SolutionOverview.png" width="700"/>
</p>
<h2>Overview</h2>
The modeling system is designed to build complete models with price, promotions and competitive terms and flexible enough for exploratory & Ad Hoc modeling. The Model of POC is based on R implementation on RStudio® IDE and Azure ML Studio and is published in the Cortana Gallery :
https://gallery.cortanaintelligence.com/Experiment/Digital-Foundry-Demand-Forecasting

<p align="center">
<img src="https://github.com/kumarchinnakali/digital-foundry-demand-forcasting/blob/master/Images/ModelSceenshot.png" width="500"/>
</p>

<h2> Forecast Model selection </h2>
<p>
A multiple regression model was used to estimate demand (SALES) by incorporating historical data available as well as through other factors influencing the demand. The model was built at a Product-Market level (lowest level of granularity) 
Model equation: </p>
<p align="center">Demand ie; Sales = f (Price, Discount, Other influencing factors*) </p>
<p>*Other influencing factors – Holiday variables, seasonality, Promotion support (Feature, Display), competitior’s effect etc.</p>

<h2>Model Set-Up & Basics – Data Preparation</h2>
<p>The model necessitated the addition of derived & external variables:
<ul style="list-style-type:disc">
  <li>Discount</li>
  <li>Competitor’s effect</li>
  <li>Holiday variables
    <ul>
      <li>New Year Day</li>
       <li> Easter </li> 
       <li>Memorial Day </li>
       <li>Labor Day </li> 
       <li>Independence Day </li>
       <li>Superbowl </li>
       <li>Thanksgiving </li>
      <li>Christmas </li>
    </ul>
  </li>
</ul>
Holiday variables were incorporated into the model to account for the change in consumption pattern during the various holidays in the US. In addition to the holiday itself, effects of shopping behavior pre- (that is, before the holiday) was also captured during the relevant week.
</p>
<h2>High level process flow in Azure ML</h2>
<p>Refer the document: 
https://github.com/kumarchinnakali/digital-foundry-demand-forcasting/blob/master/BuildModel/DF2model.pdf
</p>
<h2>Model Results and Diagnostics</h2>
<p>Fitted-salesunits and actual-salesunits are plotted against Weekending dates to capture their varying trends. Comparing Predictions from Causal Model and STLM model:</p>
<p align="center">
<img src="https://github.com/kumarchinnakali/digital-foundry-demand-forcasting/blob/master/Images/CausalOutput.PNG" width="700"/>
</p>
<p align="center">
<img src="https://github.com/kumarchinnakali/digital-foundry-demand-forcasting/blob/master/Images/STLMOutput.PNG" width="700"/>
</p>
<h2>Model Evaluation</h2>
<p>ModeL Evaluation is doen by calculating accuracy and MAPE Error for causal model and MASE Error for Decomposition and Croston Method bulit model.</p>
