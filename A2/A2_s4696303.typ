#import "../template.typ": (
  PRINT_MARGIN, default-config, end-page, executive-summary, feature-list, image-break, image-divider,
  invisible-heading, style-text, styled-outline, table-list, template,
)
#import "@preview/pintorita:0.1.4"

#set heading(numbering: "1.")

#show raw.where(lang: "pintora"): it => pintorita.render(it.text)
#show raw.where(block: true): set text(size: 8pt)

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
  title: "INFS3200 A2",
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

= Q1

```python
from a2.src import P4
from a2.src.helpers import nested_loop
from p4.DataLinkage_py.src.data.db_loader import db_loader
from p4.DataLinkage_py.src.data.measurement import calc_measure, load_benchmark


# REF: https://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Levenshtein_distance#Python
def levenshtein(s1, s2):
    if len(s1) < len(s2):
        return levenshtein(s2, s1)

    # len(s1) >= len(s2)
    if len(s2) == 0:
        return len(s1)

    previous_row = range(len(s2) + 1)
    for i, c1 in enumerate(s1):
        current_row = [i + 1]
        for j, c2 in enumerate(s2):
            insertions = (
                previous_row[j + 1] + 1
            )  # j+1 instead of j since previous_row and current_row are one character longer
            deletions = current_row[j] + 1  # than s2
            substitutions = previous_row[j] + (c1 != c2)
            current_row.append(min(insertions, deletions, substitutions))
        previous_row = current_row

    return previous_row[-1]


if __name__ == "__main__":
    restaurants = db_loader()
    benchmark = load_benchmark(P4 / "data" / "restaurant_pair.csv")
    for t in [0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]:
        count = 0
        res = []
        for i, j in nested_loop(restaurants):
            name1 = i.get_name()
            name2 = j.get_name()
            edi_dist = levenshtein(name1, name2)
            sim = 1 - (edi_dist / max(len(name1), len(name2)))
            if sim >= t:
                count += 1
                res.append(f"{str(i.get_id())}_{str(j.get_id())}")

        print(f"Threshold: {t} similar count: {count}")
        calc_measure(res, benchmark)
        print("------------------------------")
```

#image("assets/t1.1.png")

== Q2

```python
from a2.src import P4
from a2.src.helpers import nested_loop
from p4.DataLinkage_py.src.data.db_loader import db_loader
from p4.DataLinkage_py.src.data.measurement import calc_measure, load_benchmark


def qgram(str: str, q: int) -> set[str]:
    return {str[i : i + 1] for i in range(len(str) - q + 1)}


def jaccard(qgram1: set, qgram2: set):
    if not qgram1 or not qgram2:
        return 1.0
    return len(qgram1 & qgram2) / len(qgram1 | qgram2)


if __name__ == "__main__":
    restaurants = db_loader()
    benchmark = load_benchmark(P4 / "data" / "restaurant_pair.csv")
    for q in [2, 3, 4]:
        for t in [0.6, 0.7, 0.8, 0.9, 1.0]:
            count = 0
            res = []
            for i, j in nested_loop(restaurants):
                name1 = i.get_name()
                name2 = j.get_name()
                sim = jaccard(qgram(name1, q), qgram(name2, q))
                if sim >= t:
                    count += 1
                    res.append(f"{str(i.get_id())}_{str(j.get_id())}")

            print(f"Q: {q} Threshold: {t} similar count: {count}")
            calc_measure(res, benchmark)
            print("------------------------------")
```

#image("assets/t1.2.png")

== Q3

```python
from a2.src import P4
from a2.src.helpers import nested_loop
from a2.src.task1.q2 import jaccard, qgram
from p4.DataLinkage_py.src.data.db_loader import db_loader
from p4.DataLinkage_py.src.data.measurement import calc_measure, load_benchmark

if __name__ == "__main__":
    restaurants = db_loader()
    benchmark = load_benchmark(P4 / "data" / "restaurant_pair.csv")
    q = 3
    max_f_measure = 0
    max_a = 0
    for a in [0.5, 0.7, 0.9]:
        for t in [0.5, 0.7, 0.9]:
            count = 0
            res = []
            for i, j in nested_loop(restaurants):
                name1 = i.get_name()
                addr1 = i.get_address()
                name2 = j.get_name()
                addr2 = j.get_address()
                sim_name = jaccard(qgram(name1, q), qgram(name2, q))
                sim_addr = jaccard(qgram(addr1, q), qgram(addr2, q))
                sim = a * sim_name + (1 - a) * sim_addr
                if sim >= t:
                    count += 1
                    res.append(f"{str(i.get_id())}_{str(j.get_id())}")

            print(f"Q: {q} Threshold: {t} similar count: {count}")
            _, _, f_measure = calc_measure(res, benchmark)
            print("------------------------------")
            if f_measure > max_f_measure:
                max_f_measure = f_measure
                max_a = a
    print(f"Max pair ({max_a}, {max_f_measure})")
```

#image("assets/t1.3.png")

= Task2

= Q1
First we build out the star schema
```pintora
erDiagram
STAFF {
  int SID PK
  Varchar(20) FNAME
  Varchar(20) LNAME
  Varchar(10) STATE
  Varchar(20) STORE
}
TIMEPERIOD {
  int TID PK
  int day
  int month
  int quarter
  int year
}
PRODUCT {
  int PID PK
  Varchar(40) PRODUCT
  Varchar(40) BRAND
}
SALES {
  int SID PK
  int TID pk
  int PID pk
  Decimal(10, 2) UNIT_COST
  int QUANTITY
  Decimal(10, 2) PRICE
}

SALES ||--|{ STAFF : "sold by"
SALES ||--|{ PRODUCT : sold
SALES ||--|{ TIMEPERIOD : "sold on"
```
then we create this in postgres
```sql
CREATE DATABASE "A2";
\c "A2"
CREATE USER "a2" WITH PASSWORD 'infs3200';
GRANT ALL PRIVILEGES ON DATABASE "A2" TO "a2";
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT ALL ON TABLES TO "a2";
CREATE TABLE staff (sid int PRIMARY KEY, fname VARCHAR(20), lname VARCHAR(20), state VARCHAR(10), store VARCHAR(20) );
CREATE TABLE timeperiod (tid int PRIMARY KEY, day int, month int, quarter int, year int);
CREATE TABLE product (pid int PRIMARY KEY, product VARCHAR(40), brand VARCHAR(40));
CREATE TABLE SALES (
    sid int,
    tid int,
    pid int,
    unit_cost Decimal(10, 2),
    quantity int,
    price Decimal(10, 2),
    PRIMARY KEY (sid, tid, pid),
    CONSTRAINT fk_staff FOREIGN KEY (sid) REFERENCES staff(sid),
    CONSTRAINT fk_timeperiod FOREIGN KEY (tid) REFERENCES timeperiod(tid),
    CONSTRAINT fk_product FOREIGN KEY (pid) REFERENCES product(pid)
);
```

#image("assets/t2.1.png")
Next we need to load data in we'll do that with the following script
```python
from datetime import datetime
from math import ceil
from pathlib import Path

from p4.DataLinkage_py.src.psql.DBconnect import create_connection

ROOT = Path(__file__).parent

if __name__ == "__main__":
    conn = create_connection(database="A2", user="a2")
    count = 0
    with conn.cursor() as cur:
        cur.execute("TRUNCATE TABLE staff, timeperiod, product, sales;")
        with open(ROOT / "Sales.csv", "r") as f:
            # Skip the first line
            f.readline()
            while True:
                line = f.readline()
                if not line:
                    break
                line = line.replace("'", " ")
                line = line.split(",")
                # TID,SID,FNAME,LNAME,STATE,STORE,DATE,PID,BRAND,PRODUCT,UNIT_COST,QUANTITY,PRICE
                (
                    tid,
                    sid,
                    fname,
                    lname,
                    state,
                    store,
                    date,
                    pid,
                    brand,
                    product,
                    unit_cost,
                    quantity,
                    price,
                ) = line
                # Make the bold assumption that the data is clean and accept only the first copy
                cur.execute(
                    """INSERT INTO staff (sid, fname, lname, state, store)
                    VALUES (%s, %s, %s, %s, %s) ON CONFLICT (sid) DO NOTHING;""",
                    (sid, fname, lname, state, store),
                )
                sale_date = datetime.fromisoformat(date)
                cur.execute(
                    """INSERT INTO timeperiod (tid, day, month, quarter, year) VALUES (%s, %s, %s, %s, %s) ON CONFLICT (tid) DO NOTHING""",
                    (
                        tid,
                        sale_date.day,
                        sale_date.month,
                        ceil(sale_date.month / 3),
                        sale_date.year,
                    ),
                )
                cur.execute(
                    """INSERT INTO product (pid, product, brand) VALUES (%s, %s, %s) ON CONFLICT (pid) DO NOTHING""",
                    (pid, brand, product),
                )
                cur.execute(
                    """INSERT INTO sales (sid, tid, pid, unit_cost, quantity, price) VALUES (%s, %s, %s, %s, %s, %s)""",
                    (sid, tid, pid, unit_cost, quantity, price),
                )
                count += 1
    conn.commit()
    print(f"Added {count} rows")
```
#image("assets/t2.1.2.png")

== Q2
=== a
```sql
SELECT COUNT(*) FROM staff;
```

#image("assets/t2.1.2.png")

Because the insert script doesn't allow duplicates we can just count the whole table

=== b
```sql
SELECT COUNT(*) FROM sales s INNER JOIN timeperiod t ON t.tid = s.tid WHERE t.year = 2022 AND t.quarter = 3;
```

#image("assets/t2.1.2.png")


== Q3
```sql
CREATE MATERIALIZED VIEW "Sales_Time_Staff" AS
SELECT s.sid as sid, s.state as state, s.store as store, t.day as day, t.month as month, t.quarter as quarter, t.year as year,
    SUM(fs.quantity * fs.price) as total_profit, SUM(fs.quantity * fs.unit_cost) as total_cost, SUM(fs.quantity * (fs.price - fs.unit_cost)) as gross_profit, SUM(fs.quantity) as total_sold
FROM sales as fs
INNER JOIN staff s ON fs.sid = s.sid
INNER JOIN timeperiod t ON fs.tid = t.tid
GROUP BY ROLLUP (s.sid, s.state, s.store), ROLLUP (t.day, t.month, t.quarter, t.year);
```

#image("assets/t3.1.png")

== Q4
=== a
```sql
SELECT SUM(total_profit) FROM "Sales_Time_Staff" WHERE year = 2021 AND quarter = 4;
```
#image("assets/t4.a.png")
