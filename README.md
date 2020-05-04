# DuringWork
## This repo. records codes dunring working including Python3, mySQL scripts ,and Java8.

- **TifRenameApi**  
This API is a tool to help rename a large amount of files with python 3.
  - UserGuild:  
      1. Download the package including API, demo_code, and test data and put them in the same folder.
      2. Run the demo_code.
      3. You need to input the file path and the "Source Csv File" made by you. (or you can just use the test data and test csv file)

- **FeatureGenApi**  
This API contains two class. 
  - "TimeGroupGen" is a tool help deal with time serious data to transform them into specific time interval. It can one-time seperatly transform several user's searching time series data and grouping them one by one and generate 2 new columns named "GROUP_SIMILAR_IP" and "GROUP_SIMILAR_GROUP".
  - "QueryNumberGen" is a tool help count the query numbers from several users. It can one-time seperatly count several user's searching data and generate a new feature column named "QUERY_NUMBER"
  - UserGuild:  
      1. Download the package including the Api, demo_code, and the test data. Put them in the same folder.
      2. Run the demo_code and choose the designated Api you want.
      3. It will output a pandas dataframe with pk and new features.
