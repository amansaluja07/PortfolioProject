libname mylib "/home/u60695761/Ban 130/Project/home/u60695761/Ban 130/Project/AdventureWorks_2.xlsx";

/* Creating Product dataset*/
proc import 
out  = ban130.product
datafile="/home/u60695761/Ban 130/Project/AdventureWorks_2.xlsx"
DBMS=xlsx REPLACE;
sheet= product;
getnames=yes;
run;

/* Creating SalesOrderDetail dataset*/
proc import 
out  = ban130.SalesOrderDetail
datafile="/home/u60695761/Ban 130/Project/AdventureWorks_2.xlsx"
DBMS=xlsx REPLACE;
sheet= SalesOrderDetail;
getnames=yes;
run;

/* Data Cleaning on product dataset*/
data Product_Clean;
set ban130.product(Keep= ProductID Name ProductNumber Color ListPrice);
if Color =" " then color ="NA";

   List_price=input(Listprice, 10.2);
   format List_price dollar10.2;
   drop Listprice;
   rename List_price=Listprice;
run;

Title "Product Dataset";
proc print data=product_clean(obs=10);
run;

proc contents data=product_clean;
run;


/* Data Cleaning on SalesOrderDetail dataset*/
data SalesOrderDetail_Clean ;
set ban130.salesorderdetail(keep= SalesOrderID SalesOrderDetailID OrderQty ProductID UnitPrice LineTotal ModifiedDate);

where year(datepart(input(modifieddate, anydtdtm.))) in (2013, 2014);
	
	first=datepart(input(modifieddate, anydtdtm.));
	format first mmddyy10.;
	drop modifieddate;
	rename first=modifieddate;
	
second = input(UnitPrice, 10.2);
 format second dollar10.2;
   drop UnitPrice;
   rename second=UnitPrice;


third = input(LineTotal, 10.2);
format third dollar10.2;
   drop LineTotal;
   rename third=LineTotal;
   

fourth = input(OrderQty, 5.);
   drop OrderQty;
   rename fourth=OrderQty;
   
run;
 
 Title "Sales order detail Dataset";
 proc print data=salesorderdetail_clean(obs=5);
 run;

proc contents data=project.salesorderdetail_clean;
run;

proc sort data=SalesOrderDetail_Clean;
by ProductID;
run;

proc sort data=Product_Clean;
by ProductID;
run;



/* Joining and Merging */
data SalesDetails;
	merge salesorderdetail_clean(in=x) product_clean(in=y);
	by productid;
	if x;
	drop SalesOrderID SalesOrderDetailID ProductNumber ListPrice ;
run;

Title "Sales Details";
proc print data=salesdetails(obs=10);
run;

data SalesAnalysis;
set salesdetails;
by productid;
if First.productid then SubTotal=0;
SubTotal +LineTotal;

if first.productID then
		totalQty=0;
	TotalQty+OrderQty;
	
if Last.productid;

format subtotal dollar12.2;

run;

Title "Sales Analysis";
proc print data=SalesAnalysis;
run;



/* Data Analysis */

proc sql;
	title 'How many Red color Helmets are sold in 2013 and 2014?';
	select Color, TotalQty from salesAnalysis where name like '%Helmet%' 
		and color='Red';
	
	title 'How many items sold in 2013 and 2014 have a Multi color?';
	select color, sum(totalQty) "TotalOrder" from salesAnalysis where 
		color='Multi' group by color;
	
	title 'What is the combined Sales total for all the helmets sold in 2013 and 2014?';
	select 'Helmet' "ProductType", sum(totalQty) "OrderQuantity", sum(subtotal) 
		"TotalSales" from salesAnalysis where name like '%Helmet%';
	
	title 'How many Yellow Color Touring-1000 where sold in 2013 and 2014?';
	select Color, sum(TotalQty) "OrderQuantity", sum(Subtotal) "TotalSale" from 
		salesAnalysis where name like '%Touring-1000%' and color='Yellow' 
		group by color;
	
	title 'What was the total sales in 2013 and 2014?';
	select sum(TotalQty) "OrderQuantity", sum(Subtotal) "TotalSale" from 
		salesAnalysis;
	run;
	

/* Chart */

proc sgplot data=salesanalysis;
	barChart x=subtotal y=totalQty;
run;


proc sgplot data=salesanalysis;
	vbar subtotal / group=totalQty;
	yaxis grid;
run;

proc sgplot data=salesanalysis;
	bubble x=subtotal y=totalQty size=subtotal/ group=totalQty;
	xaxis grid;
	yaxis grid;
run;






