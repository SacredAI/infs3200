#import "../template.typ": (
  PRINT_MARGIN, default-config, end-page, executive-summary, feature-list, image-break, image-divider,
  invisible-heading, style-text, styled-outline, table-list, template,
)
#import "@preview/pintorita:0.1.4"

#set heading(numbering: "1.")

#show raw.where(lang: "pintora"): it => pintorita.render(it.text)

#let colors = (
  primary-background: rgb(173, 216, 230),
  primary-color: rgb("#59ade0"),
  secondary-color: rgb("#e0a0aa"),
  accent-color-1: rgb(186, 85, 211),
  accent-color-2: rgb(144, 238, 144),
  text-dark: rgb(51, 51, 51),
  text-light: rgb(51, 51, 51),
)

#let config = (
  ..default-config,
  colors: colors,
  title: "INFS3200 A1",
  sub-title: "Alex Donnellan (46963037)",
  paper: "us-letter",
  show-title: true,
)

#show: template.with(
  title: config.title,
  sub-title: config.sub-title,
  colors: config.colors,
  config: config,
)

#show: body => {
  for elem in body.children {
    if elem.func() == math.equation and elem.block {
      let numbering = if "label" in elem.fields().keys() { "(1)" } else { none }
      set math.equation(numbering: numbering)
      elem
    } else {
      elem
    }
  }
}

#styled-outline()

#pagebreak()

= Task 1

== 1.A
```sql
SELECT COUNT(*) FROM employees;
```
#image("assets/t1.a.png")

== 1.B
```sql
SELECT COUNT(*) FROM dept_emp WHERE dept_no = (SELECT dept_no FROM departments WHERE dept_name = 'Marketing');
```
#image("assets/t1.b.png")

= Task 2

== 2.A
```sql
CREATE TABLE IF NOT EXISTS salaries_h (
  emp_no int NOT NULL,
  salary int NOT NULL,
  from_date date NOT NULL,
  to_date date NOT NULL,
  PRIMARY KEY (emp_no, from_date),
  CONSTRAINT salaries_emp_no_fk FOREIGN KEY (emp_no) REFERENCES employees (emp_no)
) PARTITION BY RANGE (from_date);

CREATE TABLE salaries_1 PARTITION OF salaries_h FOR VALUES FROM (MINVALUE) TO ('1990-01-01');
CREATE TABLE salaries_2 PARTITION OF salaries_h FOR VALUES FROM ('1990-01-01') TO ('1992-01-01');
CREATE TABLE salaries_3 PARTITION OF salaries_h FOR VALUES FROM ('1992-01-01') TO ('1994-01-01');
CREATE TABLE salaries_4 PARTITION OF salaries_h FOR VALUES FROM ('1994-01-01') TO ('1996-01-01');
CREATE TABLE salaries_5 PARTITION OF salaries_h FOR VALUES FROM ('1996-01-01') TO ('1998-01-01');
CREATE TABLE salaries_6 PARTITION OF salaries_h FOR VALUES FROM ('1998-01-01') TO ('2000-01-01');
CREATE TABLE salaries_7 PARTITION OF salaries_h FOR VALUES FROM ('2000-01-01') TO (MAXVALUE);

TRUNCATE TABLE salaries_h;
INSERT INTO salaries_h
SELECT * FROM salaries;
```
#image("assets/t2.a.png")

== 2.B
```sql
SELECT AVG(salary) FROM salaries_h WHERE from_date >= '1996-06-30' AND from_date <= '1996-12-31';
```

#image("assets/t2.b.png")

```sql
EXPLAIN SELECT AVG(salary) FROM salaries_h WHERE from_date >= '1996-06-30' AND from_date <= '1996-12-31';
```

#image("assets/t2.b1.png")
From the plan we can see that postgres decides to make use of fragmentation by only scanning the single table that can contain the values, i.e. salaries_5.
A full scan over this table occurs as there is no index on the from_date.
The key choices postgres makes here to optimise and execute this plan are restricting to only the fragment that will contain data and donig a Parallel scan to allow checking multiple rows at a time.

== 2.c
```sql
CREATE TABLE employees_public AS
SELECT emp_no, first_name, last_name, hire_date FROM employees;

ALTER TABLE employees_public ADD PRIMARY KEY (emp_no);

CREATE TABLE employees_confidential as
SELECT emp_no, birth_date, gender FROM employees;

/* Export employees_confidential table */

CREATE DATABASE emp_confidential;

/* Connect to emp_confidential & load employees_confidential */

DROP TABLE employees_confidential;
```

#image("assets/t2.c1.png")

= Task 3

== 3.a
Lets consider each replication strategy.
First no replication, this means that each emp_no tuple is only stored at a single (usually what would be considered the 'best' site for each emp_no) site. This has a few key benefits. Namely Decreased storage costs, easier updates as you only need to update one site and much easier to maintain a single source of truth.
However it also comes with some risks, namely the site becomes a single point of failure for the emp_no, if it goes down the data becomes unavailable, costly remote data operations for joints and unions.

Secondly full replication, this means that each site contains all tuples. This provides superior performance over the no replication strategy as there is no extra network hop needed to collect data from other sites, the DDBMS also becomes much more reliable/available as data is replicated to all sites, meaning one going down doesn't make some data unavailable.
It can also allow the DDBMS to have functional 'read replicas' allow for load to be shared between servers.
This comes at the cost of increased storage requirements, update issues as updates need to propagate to all sites leading to increased write latency.

Finally partial replication is a combination of the prior two approaches. It overs similar pros to both, read load can be shared between servers, lower data storage costs than full repliation and increased availability/reliabilty than no repication.
However it does still face similar update propagation issues as full replication, with the addition of needing to manage which sites data is replicated.


== 3.b

Each strategy has a different process, no replication being the simplist as the query planner simply needs to determine which site the tuple is stored at and update it at that site.
Full replication is next with ease of update, the planner needs to perfrom the update on all sites, this would however be the slowest update process to ensure consistency across sites.
Finally partial replication requires the planner to determine which sites contain the record and tell just them to update, this would sit between no and full replication in terms of speed of update.

= Task 4

== 4.a

```sql
Create extension postgres_fdw;

Create server foreign_server Foreign data wrapper postgres_fdw OPTIONS (host 'infs3200-sharedb.zones.eait.uq.edu.au', port '5432', dbname 'sharedb');

create user mapping for "s4696303" server foreign_server options (user 'sharedb', password 'Y3Y7FdqDSM9.3d47XUWg');

Create foreign table titles (
	emp_no integer NOT NULL,
    title VARCHAR NOT NULL,
    from_date date NOT NULL,
    to_date date NOT NULL)
	server foreign_server options (schema_name 'public', table_name 'titles');

```

#image("assets/t4.a.png")

== 4.b

```sql
SELECT AVG(salary), t.title FROM salaries s
INNER JOIN employees e ON s.emp_no = e.emp_no
INNER JOIN titles t ON t.emp_no = s.emp_no
WHERE t.to_date = '9999-01-01'
GROUP BY t.title;
```

#image("assets/t4.b.png")

== 4.c

First we setup the FDW table
```sql
-- Create extension postgres_fdw;

CREATE USER emp_readonly_user WITH PASSWORD 'infs3200';

\c emp_confidential

GRANT CONNECT ON DATABASE emp_confidential TO emp_readonly_user;

GRANT USAGE ON SCHEMA public TO emp_readonly_user;

GRANT SELECT ON TABLE employees_confidential TO emp_readonly_user;

\c emp_s4696303

Create server foreign_server_emp Foreign data wrapper postgres_fdw OPTIONS (host 'localhost', port '5432', dbname 'emp_confidential');

create user mapping for "s4696303" server foreign_server_emp options (user 'emp_readonly_user', password 'infs3200');

Create foreign table employees_confidential (
	emp_no integer NOT NULL,
    birth_date date NOT NULL,
    gender varchar NOT NULL)
	server foreign_server_emp options (schema_name 'public', table_name 'employees_confidential');
```

#image("assets/t4.c1.png")
#image("assets/t4.c2.png")

Now we can perform the semi join

```sql
SELECT first_name, last_name FROM employees_public eps,
(SELECT ec.emp_no, ec.birth_date FROM employees_confidential ec, (SELECT emp_no FROM employees_public) ep WHERE ec.emp_no = ep.emp_no) fr
WHERE fr.emp_no = eps.emp_no AND fr.birth_date >= '1970-01-01' AND fr.birth_date <= '1975-01-01';
```

#image("assets/t4.c3.png")

however there are no results returned, we can validate that this is try by checking the employees confidential table and validating against the existing employees table

#image("assets/t4.c4.png")

== 4.d

For an inner-join we directly send all necessary attributes from the remote site to the local site
```sql
SELECT first_name, last_name FROM employees eps
INNER JOIN employees_confidential ec ON ec.emp_no = eps.emp_no
WHERE ec.birth_date >= '1970-01-01' AND ec.birth_date <= '1975-01-01';
```

#image("assets/t4.d1.png")

In this case the semi-join will have a higher transmission cost as it has to transmit the initial emp_no to match and transmit back the emp_no & their respecitve birthdates.
It could be switched around by mooving the birth_date filter condtion inside the semi-join so that it occurs at the remote site, like so
```sql
SELECT first_name, last_name FROM employees_public eps,
(SELECT ec.emp_no, ec.birth_date FROM employees_confidential ec, (SELECT emp_no FROM employees_public) ep WHERE ec.emp_no = ep.emp_no
AND ec.birth_date >= '1970-01-01' AND ec.birth_date <= '1975-01-01') fr
WHERE fr.emp_no = eps.emp_no;
```
The above (for our current data set) significantly reduces the transmission cost as no rows match the predicate so only minimal information is needed for the transmission.
