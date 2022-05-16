*** Settings ***
Documentation    Mysql execution using robot framework
Metadata  Job Execution Date  ${JOB_RUN_DATE_YYYYMMDD}
Metadata  Test Execution Date  ${TEST_RUN_DATE_YYYYMMDD}
Metadata  Environment  ${ENV}
Library  Collections
Library  DatabaseLibrary
Library  OperatingSystem
Library  pymysql
#Library  ../libs/emailutil.py
Library    DateTime
Suite Setup  connect to database  pymysql   ${dbname}  ${dbuser}   ${dbpasswd}  ${dbhost}   ${dbport}
#Suite Teardown   Disconnect from Database
Suite Teardown   tear down keywords
*** Variables ***
${dbname}    customers
${dbuser}    root
${dbpasswd}  Uday@1997
${dbhost}    127.0.0.1
${dbport}    3306
@{queryResults}
@{result}
${columnResults}=  [('cost',),  ('order_id',),  ('order_num',),  ('person_id',),  ('product',)]
${JOB_RUN_DATE_YYYYMMDD} =  20220429
${TEST_RUN_DATE_YYYYMMDD}
${year} =  ${JOB_RUN_DATE_YYYYMMDD}[:4]
${month} =  ${JOB_RUN_DATE_YYYYMMDD}[4:6]
${day} =  ${JOB_RUN_DATE_YYYYMMDD}[6:]
${ENV} =  TEST

*** Test Cases ***
TC_01
    [Documentation]  connect to mysql database and verify fields in customerdata table
    [Tags]  table check
    #Connect To Database pymysql  ${dbname} ${dbuser} ${dbpasswd} ${dbhost} ${dbport}
    Table Must Exist  customerdata
    #Check If Exists In Database  SELECT * FROM customerdata where id=11
    @{queryResults}  Query  SELECT id,firstname FROM customerdata where id=11
    #Log  @{queryResults}
    log  ${queryResults[0][0]},${queryResults[0][1]}
    ${result}  set variable  ${queryResults[0][1]}
TC_02
    [Documentation]  verify columns in orders table
    [Tags]  columns check
    @{queryResults}  Query  select column_name FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'orders'
    ${result} =  create list  @{queryResults}
    #${columnResult} =  create list  ${columnResults}
    log  ${result}
    log  ${columnResults}
    #log  ${columnResult}
    printing
    #${type result} =  evaluate  type(${result})
    #${type columnResults} =  evaluate  type(${columnResults})
    #${type columnResult} =  evaluate  type(${columnResult})
    #${type columnResults1} =  evaluate  type(@{columnResults})
    Should Be Equal as strings  ${result}  ${columnResults}  ignore_order=True
    #Lists Should Be Equal  ${columnResults}  ${result}  ignore_order=True
    Row Count Is Equal To X  select column_name FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'orders'  5
TC_03
    [Documentation]  verify rowcount in customerdata table
    [Tags]  Row count
    ${rowcount}  row count  select * from customerdata  #approach 1
    log  ${rowcount}
    #row count is equal to x  select * from customerdata  4  #approach 2
    Should Be Equal As Integers  ${rowcount}  4
TC_04
    [Documentation]  verify condition if exists in transaction table
    [Tags]  exists
    Check If Exists In Database  select name from transaction where id=11
    ${queryResults}  Query  SELECT name FROM transaction where id=11
TC_05
    [Documentation]  verify constraints check in customerdata table
    [Tags]  primary key constraints check
    Row Count is 0  select count(id) from customerdata group by id having count(id)>1 and id is not null
TC_06
    [Documentation]  verify columns count in customerdata table
    [Tags]  columns count
    Row Count Is Equal To X  select column_name FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'customerdata'  6
TC_07
    [Documentation]  verify row count using queries
    [Tags]  row count using query
    ${rowcount1}  row count  select * from transaction
    ${rowcount2}  row count  SELECT * FROM customers.customerdata;
    should be equal as Integers  ${rowcount1}  ${rowcount2}
TC_08
    [Documentation]  verify records
    [Tags]  verify records query
    ${val} =  query  SELECT cost FROM customers.orders where order_id=4;
    Should Be Equal as strings  ${val}  ((None,),)
TC_09
    [Documentation]  verify table description
    [Tags]  verify description query
    @{val} =  description  SELECT * FROM customers.orders
    Log many  @{val}
TC_10
    [Documentation]  verify count
    [Tags]  verify count query
    @{val} =  Query  SELECT count(*) FROM customers.orders
    ${count} =  convert to integer  @{val}[0]
    @{value} =  Query  SELECT count(*) FROM customers.orders
    ${count_v} =  convert to integer  @{val}[0]
    should be equal as integers  ${count}  ${count_v}

TC_11
    [Documentation]  verify dict
    [Tags]  verify list[dict]
    @{o}  create list  {'count':40}
    ${out}  convert to integer   ${o}[0][9:11]
    ${d}  create dictionary  count  40
    ${l}  convert to integer  ${d}[count]
    should be equal as integers  ${out}  ${l}

TC_12
    [Documentation]  verify add time to date
    Date
    #emailutil.Send Email

*** Keywords ***
printing
    ${type result} =  evaluate  type(${result})
    ${type columnResults} =  evaluate  type(${columnResults})

Date
    ${date}  Get Current Date    result_format=%Y%m%d

tear down keywords
    disconnect from database
    #emailutil.send_email
