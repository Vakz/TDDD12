/* -----------------  3  --------------------- */
# Create manager table
CREATE TABLE jbmanager(
	id Integer NOT NULL,
    bonus Integer DEFAULT 0,
    
    constraint pk_id
    PRIMARY KEY (id),
    
    constraint fk_manager_employee
    FOREIGN KEY (id) references jbemployee(id)
);

# Insert existing managers
INSERT INTO jbmanager(id)
SELECT DISTINCT manager FROM jbemployee
WHERE manager IS NOT NULL
UNION
SELECT DISTINCT manager FROM jbdept
WHERE manager IS NOT NULL;

# Remove the old supervisor foreign key, and create new referencing our new manager table
ALTER TABLE jbemployee
DROP FOREIGN KEY fk_emp_mgr,
ADD CONSTRAINT fk_employee_manager FOREIGN KEY (manager) REFERENCES jbmanager(id)
ON DELETE SET NULL ON UPDATE RESTRICT;

# Remove the old dept manager foreign key, and create new referencing our new manager table
ALTER TABLE jbdept
DROP FOREIGN KEY fk_dept_mgr,
ADD CONSTRAINT fk_dept_manager FOREIGN KEY (manager) REFERENCES jbmanager(id)
ON DELETE SET NULL ON UPDATE RESTRICT;

/*
 Had to initialize bonus to 0, as arithmetic doesn't work with null values
 */

/* -----------------  4  ----------------- */
# Give bonuses to department managers
UPDATE jbmanager
SET bonus = bonus + 10000
WHERE id in (SELECT distinct manager FROM jbdept);

/* ------------------  5  ---------------- */
# Adding customer table
CREATE TABLE jbcustomer(
	id Integer NOT NULL AUTO_INCREMENT,
    address varchar(30) NOT NULL,
    name varchar(30) NOT NULL,
    city Integer NOT NULL,
    
    constraint pk_id
    PRIMARY KEY (id),
    
    constraint fk_customer_city
    FOREIGN KEY (city) REFERENCES jbcity(id)
);

# Create account table
CREATE TABLE jbaccount(
	id Integer NOT NULL AUTO_INCREMENT,
    balance Integer NOT NULL default 0,
    owner Integer NOT NULL,
    
    constraint pk_id
    PRIMARY KEY (id),
    
    constraint fk_account_customer
    FOREIGN KEY (owner) REFERENCES jbcustomer(id)
);

# As debit contains the columns transaction will have, we simply rename it. We also add a column for amount
RENAME TABLE jbdebit TO jbtransaction;
ALTER TABLE jbtransaction
ADD amount Integer NOT NULL;

# Create a new debit table
CREATE TABLE jbdebit (
	id Integer NOT NULL,
    
    constraint pk_id
    PRIMARY KEY (id),
    
    constraint fk_debit_transaction
    FOREIGN KEY (id) REFERENCES jbtransaction(id)
);

UPDATE jbtransaction
INNER JOIN jbsale ON jbsale.debit = jbtransaction.id
INNER JOIN jbitem ON jbitem.id = jbsale.item
SET amount = quantity * price;

# Delete the debit which had not been involved in a transaction
DELETE FROM jbtransaction
WHERE amount = 0;

# All currently existing transaction are debits
INSERT INTO jbdebit
SELECT id FROM jbtransaction;

SELECT * FROM jbtransaction;

# Move the foreign key which currently connects jbtransaction and jbsale (due to the renaming) to jbdebit - jbsale
ALTER TABLE jbsale
DROP FOREIGN KEY fk_sale_debit;

ALTER TABLE jbsale
ADD FOREIGN KEY fk_sale_debit (debit) REFERENCES jbdebit(id);

# Add account foreign key for transactions
/*
This can't be done, since the existing transactions are linked to accounts which do not exist,
nor do customers exists which can be linked to accounts, which means we can't create the accounts
ourselves either
ALTER TABLE jbtransaction
ADD FOREIGN KEY fk_transaction_account (account) REFERENCES jbaccount(id);
*/

SELECT * FROM jbtransaction;

CREATE TABLE jbwithdraw(
	id Integer NOT NULL,
    
    constraint pk_id PRIMARY KEY (id),
    
    constraint fk_withdraw_transaction
    FOREIGN KEY (id) REFERENCES jbtransaction(id)
);

CREATE TABLE jbdeposit(
	id Integer NOT NULL,
    
    constraint pk_id PRIMARY KEY (id),
    
    constraint fk_deposit_transaction
    FOREIGN KEY (id) REFERENCES jbtransaction(id)
);