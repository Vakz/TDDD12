# 1 Lists all employees
SELECT * FROM jbemployee;

/*
# id, name, salary, manager, birthyear, startyear
10, Ross, Stanley, 15908, 199, 1927, 1945
11, Ross, Stuart, 12067, , 1931, 1932
13, Edwards, Peter, 9000, 199, 1928, 1958
26, Thompson, Bob, 13000, 199, 1930, 1970
32, Smythe, Carol, 9050, 199, 1929, 1967
33, Hayes, Evelyn, 10100, 199, 1931, 1963
35, Evans, Michael, 5000, 32, 1952, 1974
37, Raveen, Lemont, 11985, 26, 1950, 1974
55, James, Mary, 12000, 199, 1920, 1969
98, Williams, Judy, 9000, 199, 1935, 1969
129, Thomas, Tom, 10000, 199, 1941, 1962
157, Jones, Tim, 12000, 199, 1940, 1960
199, Bullock, J.D., 27000, , 1920, 1920
215, Collins, Joanne, 7000, 10, 1950, 1971
430, Brunet, Paul C., 17674, 129, 1938, 1959
843, Schmidt, Herman, 11204, 26, 1936, 1956
994, Iwano, Masahiro, 15641, 129, 1944, 1970
1110, Smith, Paul, 6000, 33, 1952, 1973
1330, Onstad, Richard, 8779, 13, 1952, 1971
1523, Zugnoni, Arthur A., 19868, 129, 1928, 1949
1639, Choy, Wanda, 11160, 55, 1947, 1970
2398, Wallace, Maggie J., 7880, 26, 1940, 1959
4901, Bailey, Chas M., 8377, 32, 1956, 1975
5119, Bono, Sonny, 13621, 55, 1939, 1963
5219, Schwarz, Jason B., 13374, 33, 1944, 1959
*/

# 2 List all departments sorted by name
SELECT * FROM jbdept ORDER BY name;

/*
# id, name, store, floor, manager
1, Bargain, 5, 0, 37
35, Book, 5, 1, 55
10, Candy, 5, 1, 13
73, Children's, 5, 1, 10
43, Children's, 8, 2, 32
19, Furniture, 7, 4, 26
99, Giftwrap, 5, 1, 98
14, Jewelry, 8, 1, 33
47, Junior Miss, 7, 2, 129
65, Junior's, 7, 3, 37
26, Linens, 7, 3, 157
20, Major Appliances, 7, 4, 26
58, Men's, 7, 2, 129
60, Sportswear, 5, 1, 10
34, Stationary, 5, 1, 33
49, Toys, 8, 2, 35
63, Women's, 7, 3, 32
70, Women's, 5, 1, 10
28, Women's, 8, 2, 32

*/

# 3 List all parts which are out of stock
SELECT * FROM jbparts WHERE qoh=0;
/*
# id, name, color, weight, qoh
11, card reader, gray, 327, 0
12, card punch, gray, 427, 0
13, paper tape reader, black, 107, 0
14, paper tape punch, black, 147, 0

*/

# 4 List all employees with salary [9000, 10000]
SELECT * FROM jbemployee WHERE salary BETWEEN 9000 AND 10000;
/*
# id, name, salary, manager, birthyear, startyear
13, Edwards, Peter, 9000, 199, 1928, 1958
32, Smythe, Carol, 9050, 199, 1929, 1967
98, Williams, Judy, 9000, 199, 1935, 1969
129, Thomas, Tom, 10000, 199, 1941, 1962

*/

# 5 List employees, calculate age at employment
SELECT id,name,birthyear,startyear,(startyear - birthyear) AS start_age FROM jbemployee;
/*
# id, name, birthyear, startyear, start_age
10, Ross, Stanley, 1927, 1945, 18
11, Ross, Stuart, 1931, 1932, 1
13, Edwards, Peter, 1928, 1958, 30
26, Thompson, Bob, 1930, 1970, 40
32, Smythe, Carol, 1929, 1967, 38
33, Hayes, Evelyn, 1931, 1963, 32
35, Evans, Michael, 1952, 1974, 22
37, Raveen, Lemont, 1950, 1974, 24
55, James, Mary, 1920, 1969, 49
98, Williams, Judy, 1935, 1969, 34
129, Thomas, Tom, 1941, 1962, 21
157, Jones, Tim, 1940, 1960, 20
199, Bullock, J.D., 1920, 1920, 0
215, Collins, Joanne, 1950, 1971, 21
430, Brunet, Paul C., 1938, 1959, 21
843, Schmidt, Herman, 1936, 1956, 20
994, Iwano, Masahiro, 1944, 1970, 26
1110, Smith, Paul, 1952, 1973, 21
1330, Onstad, Richard, 1952, 1971, 19
1523, Zugnoni, Arthur A., 1928, 1949, 21
1639, Choy, Wanda, 1947, 1970, 23
2398, Wallace, Maggie J., 1940, 1959, 19
4901, Bailey, Chas M., 1956, 1975, 19
5119, Bono, Sonny, 1939, 1963, 24
5219, Schwarz, Jason B., 1944, 1959, 15

*/

# 6 List employees whose name end in 'son'
SELECT * FROM jbemployee WHERE name LIKE '%son,%';
/*
# id, name, salary, manager, birthyear, startyear
26, Thompson, Bob, 13000, 199, 1930, 1970

*/

# 7 List all parts supplied by 'Fisher-Price' with subquery
SELECT * FROM jbitem WHERE supplier IN
(SELECT id FROM jbsupplier WHERE name="Fisher-Price");
/*
# id, name, dept, price, qoh, supplier
43, Maze, 49, 325, 200, 89
107, The 'Feel' Book, 35, 225, 225, 89
119, Squeeze Ball, 49, 250, 400, 89

*/

# 8 List all parts supplied by 'Fisher-Price' without subquery
SELECT * FROM jbitem, jbsupplier
WHERE jbitem.supplier=jbsupplier.id AND jbsupplier.name="Fisher-Price";
/*
# id, name, dept, price, qoh, supplier, id, name, city
43, Maze, 49, 325, 200, 89, 89, Fisher-Price, 21
107, The 'Feel' Book, 35, 225, 225, 89, 89, Fisher-Price, 21
119, Squeeze Ball, 49, 250, 400, 89, 89, Fisher-Price, 21
*/

# 9 List all cities with a supplier using subquery
SELECT * FROM jbcity WHERE id IN
(SELECT city FROM jbsupplier);
/*
# id, name, state
10, Amherst, Mass
21, Boston, Mass
100, New York, NY
106, White Plains, Neb
118, Hickville, Okla
303, Atlanta, Ga
537, Madison, Wisc
609, Paxton, Ill
752, Dallas, Tex
802, Denver, Colo
841, Salt Lake City, Utah
900, Los Angeles, Calif
921, San Diego, Calif
941, San Francisco, Calif
981, Seattle, Wash
*/

# 10 List name and color of all parts heavier than card-reader
SELECT name, color FROM jbparts WHERE weight > (SELECT weight FROM jbparts WHERE name="card reader");
/*
# name, color
disk drive, black
tape drive, black
line printer, yellow
card punch, gray
*/

# 11 List name and color of all parts heavier than card-reader without subquery
SELECT p.name,p.color FROM jbparts p, jbparts q WHERE p.weight > q.weight AND q.name="card reader";
/*
# name, color
disk drive, black
tape drive, black
line printer, yellow
card punch, gray
*/

#12 List average weight of black parts
select AVG(weight) FROM jbparts WHERE color="black";
/*
# AVG(weight)
347.2500
*/

#13 List mass of all delivered parts of each supplier in Massachusetts
SELECT name, sum(total_weight) FROM
(SELECT (sum(quan) * weight) as total_weight, jbsupply.*, jbparts.weight, jbsupplier.name
FROM jbparts, jbsupplier, jbsupply
WHERE jbparts.id = jbsupply.part AND jbsupplier.id = jbsupply.supplier AND
jbsupply.supplier IN (SELECT s.id FROM jbsupplier s, jbcity c WHERE s.city = c.id AND c.state="Mass")
GROUP BY part,supplier) as some_table
GROUP BY name;
/*
# name, sum(total_weight)
DEC, 3120
Fisher-Price, 1135000
*/

#14 Create table with same columns are jbitem, then fill with all items which cost less than average
CREATE TABLE jbbelowaverage (
  id Integer,
  name varchar(20),
  dept Integer NOT NULL,
  price Integer,
  qoh Integer unsigned,
  supplier Integer NOT NULL,
  
  constraint pk_id
  primary key (id),
  
  constraint fk_belowaverage_dept
  FOREIGN KEY (dept) references jbdept(id),
  
  constraint fk_belowaverage_supplier
  FOREIGN KEY (supplier) references jbsupplier(id),
  
  constraint fk_belowaverage_items
  FOREIGN KEY (id) references jbitem(id)
);

INSERT INTO jbbelowaverage
SELECT * FROM jbitem HAVING jbitem.price < AVG(jbitem.price);
/*
 No output
*/

# 15 Create view with items that cost below average
CREATE VIEW jbbelowaverageview AS
SELECT * FROM jbitem HAVING jbitem.price < AVG(jbitem.price);
/*
 No output
*/

# 16 What is the difference between a table and a view?
/*
 The table is static and the view is dynamic. This means that the items in the table has to be
 updated manually when the jbitem table is changed, to make sure it's up to date. The view contains no data on 
 it's onwn, but is "linked" to jbitem, and when queried will in turn query the jbitem table, and is thus always up to date.
*/

# 17 Create view showing total cost of each debit using where
CREATE VIEW jbdebitcost AS
SELECT debit, (quantity * price) as total_cost FROM jbsale, jbitem
WHERE jbsale.item = jbitem.id;
/*
 No output
*/
SELECT * FROM jbdebitcost;
# 18 Create view showing total cost of each debit using joins
CREATE VIEW jbdebitcostjoins AS
SELECT debit, (quantity * price) as total_cost FROM jbsale
INNER JOIN jbitem
ON jbsale.item = jbitem.id;
/*
 No output. Inner Join is the correct one as we are not interested in any items which have
 not been used in a debit (which a right join would select). A left join would produce the same result
 as inner join, since all sales must refer to an item.
*/


# 19a Delete all suppliers in Los Angeles
# Delete sale history concerning items sold by suppliers in Los Angeles
DELETE FROM jbsale
WHERE item IN
(SELECT jbitem.id FROM jbitem
INNER JOIN jbsupplier ON jbitem.supplier = jbsupplier.id
INNER JOIN jbcity ON jbsupplier.city = jbcity.id AND jbcity.name="Los Angeles");
/* 1 row affected */
# Deletes all items supplied by supplier in Los Angeles
DELETE FROM jbitem
WHERE supplier IN 
(SELECT jbsupplier.id FROM jbsupplier INNER JOIN jbcity
ON jbcity.id = jbsupplier.city AND jbcity.name="Los Angeles");
/* 2 rows affected */
# Delete suppliers in Los Angeles
DELETE FROM jbsupplier
WHERE city in (SELECT id FROM jbcity WHERE name="Los Angeles");
/* 1 row affected */
# 19b
/* Due to foreign key constrains, before we can delete suppliers in Los Angeles,
   we must first delete all items supplied from Los Angeles. In turn, before we can
   delete these items, we must also delete the sale history concerning these items.
*/

# 20 Create view showing supplier sales, including suppliers with zero sales

CREATE VIEW jbsale_supply(supplier, item, quantity) AS
SELECT jbsupplier.name, jbitem.name, jbsale.quantity  
FROM jbsupplier
INNER JOIN jbitem ON jbsupplier.id = jbitem.supplier
LEFT JOIN jbsale ON jbsale.item = jbitem.id;

SELECT supplier, sum(quantity) AS sum FROM jbsale_supply
GROUP BY supplier;
/*
# supplier, sum
Cannon, 6
Fisher-Price, 
Levi-Strauss, 1
Playskool, 2
White Stag, 4
Whitman's, 2
*/
