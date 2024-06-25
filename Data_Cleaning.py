import pandas as pd
kit = pd.read_csv("C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/kit_data.csv")

from sqlalchemy import create_engine

from urllib.parse import quote

user = 'root' # 
pw = 'Salim@2001' 
db = 'automobiles'

engine = create_engine(f"mysql+pymysql://{user}:%s@localhost/{db}" % quote(f'{pw}'))

kit.to_sql('kit', con = engine, if_exists = 'replace', chunksize = None, index= False)

sql = "SELECT * FROM kit;"

anime = pd.read_sql_query(sql, engine)

kit.describe();
kit

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# **********Calculating Mean******

mean = kit['No. of Kits'].mean()
print(mean)

# ********Calculating Median********

median = kit['No. of Kits'].median()
print(median)

# *********Calculating Mode**********

mode = kit['No. of Kits'].mode()
print(mode)

# *********** Performing Auto EDA *************

#############SweetViz############

import sweetviz as sv

s = sv.analyze(kit)
s.show_html()

plt.savefig('autoviz_plot.png')


###########AutoViz############

from autoviz.AutoViz_Class import AutoViz_Class
AV = AutoViz_Class()
a = AV.AutoViz("C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/kit_data.csv")


############ D-Tale #################

import dtale

d = dtale.show(kit)
d.open_browser()


################ Pandas_Prifiling #############

from pandas_profiling import ProfileReport

p = ProfileReport(kit)
p.to_file("output.html")


############# DataPrep ##############

from dataprep import create_report

report = create_report(kit, title = 'My Report')
report.show_browser()



############# Data Pre-processing ##############

# *********** Finding Duplicates ***************

duplicate_values = kit['Customer Code'].duplicated()
print(duplicate_values)
duplicate_values = kit['Customer Name'].duplicated()
print(duplicate_values)
duplicate_values = kit['KIT ITEM'].duplicated()
print(duplicate_values)
duplicate_values = kit['OEM'].duplicated()
print(duplicate_values)
duplicate_values = kit['Item Description'].duplicated()
print(duplicate_values)
duplicate_values = kit['Product type'].duplicated()
print(duplicate_values)
duplicate_values = kit['Item Code'].duplicated()
print(duplicate_values)
duplicate_values = kit['Date'].duplicated()
print(duplicate_values)
duplicate_values = kit['No. of Kits'].duplicated()
print(duplicate_values)


kit.drop_duplicates(inplace = True)
print(kit)


# **********Finding Missing Values********

kit.isnull().sum()

# ********* Handling Missing Values *********

updated_kit = kit
updated_kit['No. of Kits']=updated_kit['No. of Kits'].fillna(updated_kit['No. of Kits'].mean())
updated_kit.info()

updated_kit.isnull().sum()



updated_kit.rename(columns={"Customer Code": "Customer_Code"}, inplace=True)
updated_kit.rename(columns={"Customer Name": "Customer_Name"}, inplace=True)
updated_kit.rename(columns={"KIT ITEM": "Kit_Item"}, inplace=True)
updated_kit.rename(columns={"Item Description": "Item_Description"}, inplace=True)
updated_kit.rename(columns={"Product type": "Product_Type"}, inplace=True)
updated_kit.rename(columns={"Item Code": "Item_Code"}, inplace=True)
updated_kit.rename(columns={"No._of_Kits": "No_of_Kits"}, inplace=True) 
 
updated_kit

# ********************** Outliers Treatment*******************

# --- Checking Outliers In Each Column-------
import pandas as pd
import numpy as np
import seaborn as sns

kit.dtypes

sns.boxplot(kit['No. of Kits'])       


# *********Winsorization***********

from feature_engine.outliers import Winsorizer  # Note: 'Winsorizer' instead of 'winsorizer'

# Instantiate the Winsorizer object
winsor_iqr = Winsorizer(capping_method='iqr', tail='both', fold=1.5, variables=['No. of Kits'])

# Fit and transform the data
updated_kit = winsor_iqr.fit_transform(kit[['No. of Kits']])

# let's see again boxplot
sns.boxplot(updated_kit)
kit['No. of Kits'] = updated_kit


sns.boxplot(kit['Item Code']) #Outliers Present

updated_kit['Item Code'] = pd.to_numeric(updated_kit['Item Code'], errors='coerce')

winsor_iqr = Winsorizer(capping_method='iqr', tail='both', fold=1.5, variables=['Item Code'])

# Fit and transform the data
updated_kit = winsor_iqr.fit_transform(kit[['Item Code']])

# let's see again boxplot
sns.boxplot(updated_kit)
kit['Item Code'] = updated_kit



##############################################
#### zero variance and near zero variance ####

import pandas as pd

variance = updated_kit.var()
near_zero_var_features = variance[variance < 0.01]
print(near_zero_var_features)


##############################################
############# Binnig/Discretization ##############

updated_kit['No. of Kits_bins'] = pd.cut(updated_kit['No. of Kits'], bins=3, 
labels=['Low', 'Medium', 'High'])

print(updated_kit)


################ Dummy Variable Creation ############

dummy_variables = pd.get_dummies(kit['Customer Name'], prefix='Customer Name')

kit_with_dummies = pd.concat([kit, dummy_variables], axis=1)

print(kit_with_dummies)



############ Data Transformation ##########

import numpy as np

kit['Value_log'] = np.log(kit['No. of Kits'])

kit['Value_log'] = np.log(kit['Customer Code'])

print(kit)



