EXPLAIN CREATE SEQUENCE seq1;
-- error 42601: syntax error: Cannot EXPLAIN CREATE SEQUENCE

CREATE SEQUENCE seq1;
EXPLAIN VALUES NEXT VALUE FOR seq1;
-- msg: CREATE SEQUENCE 1
-- EXPLAIN: VALUES (COL1 INTEGER) = ROW(NEXT VALUE FOR ":memory:".PUBLIC.SEQ1)

CREATE SEQUENCE seq1;
VALUES NEXT VALUE FOR seq1;
VALUES NEXT VALUE FOR seq1;
-- msg: CREATE SEQUENCE 1
-- COL1: 1
-- COL1: 2

CREATE SEQUENCE foo.seq1;
-- error 3F000: invalid schema name: FOO

CREATE SEQUENCE public.seq1;
VALUES NEXT VALUE FOR seq1;
VALUES NEXT VALUE FOR public.seq1;
-- msg: CREATE SEQUENCE 1
-- COL1: 1
-- COL1: 2

CREATE SCHEMA foo;
CREATE SEQUENCE foo.seq1;
-- msg: CREATE SCHEMA 1
-- msg: CREATE SEQUENCE 1

VALUES NEXT VALUE FOR seq1;
-- error 42P01: no such sequence: ":memory:".PUBLIC.SEQ1

CREATE SEQUENCE seq1;
CREATE SEQUENCE seq2;
VALUES NEXT VALUE FOR seq1;
VALUES NEXT VALUE FOR seq2;
-- msg: CREATE SEQUENCE 1
-- msg: CREATE SEQUENCE 1
-- COL1: 1
-- COL1: 1

CREATE SEQUENCE seq1 START WITH 51;
VALUES NEXT VALUE FOR seq1;
VALUES NEXT VALUE FOR seq1;
-- msg: CREATE SEQUENCE 1
-- COL1: 51
-- COL1: 52

CREATE SEQUENCE seq1 INCREMENT BY 2;
VALUES NEXT VALUE FOR seq1;
VALUES NEXT VALUE FOR seq1;
-- msg: CREATE SEQUENCE 1
-- COL1: 1
-- COL1: 3

CREATE SEQUENCE seq1 INCREMENT BY 2 START WITH 17;
VALUES NEXT VALUE FOR seq1, NEXT VALUE FOR seq1;
-- msg: CREATE SEQUENCE 1
-- COL1: 17 COL2: 19

CREATE SEQUENCE seq1 INCREMENT BY 2 MINVALUE 17;
VALUES NEXT VALUE FOR seq1, NEXT VALUE FOR seq1;
-- msg: CREATE SEQUENCE 1
-- COL1: 17 COL2: 19

CREATE SEQUENCE seq1 INCREMENT BY 3 MINVALUE 17 START WITH 24;
VALUES NEXT VALUE FOR seq1, NEXT VALUE FOR seq1;
-- msg: CREATE SEQUENCE 1
-- COL1: 24 COL2: 27

CREATE SEQUENCE seq1 START WITH 17 INCREMENT BY -2;
VALUES NEXT VALUE FOR seq1, NEXT VALUE FOR seq1;
-- msg: CREATE SEQUENCE 1
-- COL1: 17 COL2: 15

CREATE SEQUENCE seq1 INCREMENT BY -2 MAXVALUE 50;
VALUES NEXT VALUE FOR seq1, NEXT VALUE FOR seq1;
-- msg: CREATE SEQUENCE 1
-- COL1: 50 COL2: 48

CREATE SEQUENCE seq1 START WITH 17 INCREMENT BY -2 MAXVALUE 50;
VALUES NEXT VALUE FOR seq1, NEXT VALUE FOR seq1;
-- msg: CREATE SEQUENCE 1
-- COL1: 17 COL2: 15

CREATE SEQUENCE seq1 START WITH 10 INCREMENT BY 5 MAXVALUE 20 CYCLE;
VALUES NEXT VALUE FOR seq1, NEXT VALUE FOR seq1;
VALUES NEXT VALUE FOR seq1, NEXT VALUE FOR seq1;
VALUES NEXT VALUE FOR seq1, NEXT VALUE FOR seq1;
-- msg: CREATE SEQUENCE 1
-- COL1: 10 COL2: 15
-- COL1: 20 COL2: 1
-- COL1: 6 COL2: 11

CREATE SEQUENCE seq1 MINVALUE 10 INCREMENT BY 5 MAXVALUE 20 CYCLE;
VALUES NEXT VALUE FOR seq1, NEXT VALUE FOR seq1;
VALUES NEXT VALUE FOR seq1, NEXT VALUE FOR seq1;
VALUES NEXT VALUE FOR seq1, NEXT VALUE FOR seq1;
-- msg: CREATE SEQUENCE 1
-- COL1: 10 COL2: 15
-- COL1: 20 COL2: 10
-- COL1: 15 COL2: 20

CREATE SEQUENCE seq1 MINVALUE 5 INCREMENT BY 5 MAXVALUE 20 CYCLE START WITH 7;
VALUES NEXT VALUE FOR seq1, NEXT VALUE FOR seq1;
VALUES NEXT VALUE FOR seq1, NEXT VALUE FOR seq1;
VALUES NEXT VALUE FOR seq1, NEXT VALUE FOR seq1;
-- msg: CREATE SEQUENCE 1
-- COL1: 7 COL2: 12
-- COL1: 17 COL2: 5
-- COL1: 10 COL2: 15

CREATE SEQUENCE seq1 START WITH 10 INCREMENT BY 5 MAXVALUE 20 NO CYCLE;
VALUES NEXT VALUE FOR seq1;
VALUES NEXT VALUE FOR seq1;
VALUES NEXT VALUE FOR seq1;
VALUES NEXT VALUE FOR seq1;
-- msg: CREATE SEQUENCE 1
-- COL1: 10
-- COL1: 15
-- COL1: 20
-- error 2200H: sequence generator limit exceeded: PUBLIC.SEQ1

CREATE SEQUENCE seq1 START WITH 30 INCREMENT BY -5 MINVALUE 20 NO CYCLE;
VALUES NEXT VALUE FOR seq1;
VALUES NEXT VALUE FOR seq1;
VALUES NEXT VALUE FOR seq1;
VALUES NEXT VALUE FOR seq1;
-- msg: CREATE SEQUENCE 1
-- COL1: 30
-- COL1: 25
-- COL1: 20
-- error 2200H: sequence generator limit exceeded: PUBLIC.SEQ1

CREATE SEQUENCE seq1 START WITH 10 INCREMENT BY 5 MAXVALUE 20;
VALUES NEXT VALUE FOR seq1;
VALUES NEXT VALUE FOR seq1;
VALUES NEXT VALUE FOR seq1;
VALUES NEXT VALUE FOR seq1;
-- msg: CREATE SEQUENCE 1
-- COL1: 10
-- COL1: 15
-- COL1: 20
-- error 2200H: sequence generator limit exceeded: PUBLIC.SEQ1

CREATE SEQUENCE seq1 START WITH 30 INCREMENT BY -5 MINVALUE 20;
VALUES NEXT VALUE FOR seq1;
VALUES NEXT VALUE FOR seq1;
VALUES NEXT VALUE FOR seq1;
VALUES NEXT VALUE FOR seq1;
-- msg: CREATE SEQUENCE 1
-- COL1: 30
-- COL1: 25
-- COL1: 20
-- error 2200H: sequence generator limit exceeded: PUBLIC.SEQ1

CREATE SEQUENCE seq1 START WITH 10 INCREMENT BY 5 NO MAXVALUE;
VALUES NEXT VALUE FOR seq1, NEXT VALUE FOR seq1;
VALUES NEXT VALUE FOR seq1, NEXT VALUE FOR seq1;
-- msg: CREATE SEQUENCE 1
-- COL1: 10 COL2: 15
-- COL1: 20 COL2: 25

CREATE SEQUENCE seq1 START WITH 10 INCREMENT BY -5 NO MINVALUE;
VALUES NEXT VALUE FOR seq1, NEXT VALUE FOR seq1;
VALUES NEXT VALUE FOR seq1, NEXT VALUE FOR seq1;
-- msg: CREATE SEQUENCE 1
-- COL1: 10 COL2: 5
-- COL1: 0 COL2: -5
