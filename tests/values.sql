SELECT * FROM (VALUES 1);
-- COL1: 1

EXPLAIN SELECT * FROM (VALUES 1);
-- EXPLAIN: $1:
-- EXPLAIN:   VALUES (COL1 BIGINT) = ROW(1)
-- EXPLAIN: TABLE $1 (COL1 BIGINT)
-- EXPLAIN: EXPR ($1.COL1 BIGINT)

EXPLAIN SELECT * FROM (VALUES 1.23);
-- EXPLAIN: $1:
-- EXPLAIN:   VALUES (COL1 DOUBLE PRECISION) = ROW(1.23)
-- EXPLAIN: TABLE $1 (COL1 DOUBLE PRECISION)
-- EXPLAIN: EXPR ($1.COL1 DOUBLE PRECISION)

SELECT * FROM (VALUES 1.23);
-- COL1: 1.23

SELECT * FROM (VALUES 1, 'foo', TRUE);
-- COL1: 1 COL2: foo COL3: TRUE

EXPLAIN SELECT * FROM (VALUES 1, 'foo', TRUE);
-- EXPLAIN: $1:
-- EXPLAIN:   VALUES (COL1 BIGINT, COL2 CHARACTER VARYING, COL3 BOOLEAN) = ROW(1, 'foo', TRUE)
-- EXPLAIN: TABLE $1 (COL1 BIGINT, COL2 CHARACTER VARYING, COL3 BOOLEAN)
-- EXPLAIN: EXPR ($1.COL1 BIGINT, $1.COL2 CHARACTER VARYING, $1.COL3 BOOLEAN)

EXPLAIN SELECT * FROM (VALUES 1, 'foo', TRUE) AS t1 (abc, col2, "f");
-- EXPLAIN: T1:
-- EXPLAIN:   VALUES (ABC BIGINT, COL2 CHARACTER VARYING, "f" BOOLEAN) = ROW(1, 'foo', TRUE)
-- EXPLAIN: TABLE T1 (ABC BIGINT, COL2 CHARACTER VARYING, "f" BOOLEAN)
-- EXPLAIN: EXPR (T1.ABC BIGINT, T1.COL2 CHARACTER VARYING, T1."f" BOOLEAN)

SELECT * FROM (VALUES 1, 'foo', TRUE) AS t1 (abc, col2, "f");
-- ABC: 1 COL2: foo f: TRUE

VALUES 'cool';
-- COL1: cool

VALUES 'cool', 12.3;
-- COL1: cool COL2: 12.3

VALUES '12.3';
-- COL1: 12.3

VALUES '2022-06-30 21:47:32';
-- COL1: 2022-06-30 21:47:32

EXPLAIN VALUES 'hello';
-- EXPLAIN: VALUES (COL1 CHARACTER VARYING) = ROW('hello')

EXPLAIN VALUES 'hello', 1.22;
-- EXPLAIN: VALUES (COL1 CHARACTER VARYING, COL2 DOUBLE PRECISION) = ROW('hello', 1.22)

SELECT * FROM (VALUES ROW(123), ROW(456));
-- COL1: 123
-- COL1: 456

EXPLAIN SELECT * FROM (VALUES ROW(123), ROW(456));
-- EXPLAIN: $1:
-- EXPLAIN:   VALUES (COL1 BIGINT) = ROW(123), ROW(456)
-- EXPLAIN: TABLE $1 (COL1 BIGINT)
-- EXPLAIN: EXPR ($1.COL1 BIGINT)

SELECT * FROM (VALUES ROW(123, 'hi'), ROW(456, 'there'));
-- COL1: 123 COL2: hi
-- COL1: 456 COL2: there

EXPLAIN SELECT * FROM (VALUES ROW(123, 'hi'), ROW(456, 'there'));
-- EXPLAIN: $1:
-- EXPLAIN:   VALUES (COL1 BIGINT, COL2 CHARACTER VARYING) = ROW(123, 'hi'), ROW(456, 'there')
-- EXPLAIN: TABLE $1 (COL1 BIGINT, COL2 CHARACTER VARYING)
-- EXPLAIN: EXPR ($1.COL1 BIGINT, $1.COL2 CHARACTER VARYING)

SELECT * FROM (VALUES ROW(123, 'hi'), ROW(456, 'there')) AS foo (bar, baz);
-- BAR: 123 BAZ: hi
-- BAR: 456 BAZ: there

EXPLAIN SELECT *
FROM (VALUES ROW(123, 'hi'), ROW(456, 'there')) AS foo (bar, baz);
-- EXPLAIN: FOO:
-- EXPLAIN:   VALUES (BAR BIGINT, BAZ CHARACTER VARYING) = ROW(123, 'hi'), ROW(456, 'there')
-- EXPLAIN: TABLE FOO (BAR BIGINT, BAZ CHARACTER VARYING)
-- EXPLAIN: EXPR (FOO.BAR BIGINT, FOO.BAZ CHARACTER VARYING)

SELECT * FROM (VALUES 1, 2) AS t1 (foo);
-- error 42601: syntax error: ROW provides the wrong number of columns for the correlation

SELECT * FROM (VALUES 1, 2) AS t1 (foo, bar, baz);
-- error 42601: syntax error: ROW provides the wrong number of columns for the correlation

SELECT * FROM (VALUES ROW(1, 2), ROW(3, 4)) AS t1 (foo, bar);
-- FOO: 1 BAR: 2
-- FOO: 3 BAR: 4

SELECT * FROM (VALUES ROW(1, 2), ROW(3, 4)) AS t1 (foo);
-- error 42601: syntax error: ROW provides the wrong number of columns for the correlation

SELECT * FROM (VALUES ROW(1), ROW(3, 4)) AS t1 (foo, bar);
-- error 42601: syntax error: ROW provides the wrong number of columns for the correlation

EXPLAIN SELECT * FROM (VALUES ROW(1, 2), ROW(3, 4), ROW(5, 6)) AS t1 (foo, bar)
FETCH FIRST 2 ROWS ONLY;
-- EXPLAIN: T1:
-- EXPLAIN:   VALUES (FOO BIGINT, BAR BIGINT) = ROW(1, 2), ROW(3, 4), ROW(5, 6)
-- EXPLAIN: TABLE T1 (FOO BIGINT, BAR BIGINT)
-- EXPLAIN: FETCH FIRST 2 ROWS ONLY
-- EXPLAIN: EXPR (T1.FOO BIGINT, T1.BAR BIGINT)

SELECT * FROM (VALUES ROW(1, 2), ROW(3, 4), ROW(5, 6)) AS t1 (foo, bar)
FETCH FIRST 2 ROWS ONLY;
-- FOO: 1 BAR: 2
-- FOO: 3 BAR: 4

EXPLAIN SELECT * FROM (VALUES ROW(1, 2), ROW(3, 4), ROW(5, 6)) AS t1 (foo, bar)
OFFSET 1 ROW;
-- EXPLAIN: T1:
-- EXPLAIN:   VALUES (FOO BIGINT, BAR BIGINT) = ROW(1, 2), ROW(3, 4), ROW(5, 6)
-- EXPLAIN: TABLE T1 (FOO BIGINT, BAR BIGINT)
-- EXPLAIN: OFFSET 1 ROWS
-- EXPLAIN: EXPR (T1.FOO BIGINT, T1.BAR BIGINT)

SELECT * FROM (VALUES ROW(1, 2), ROW(3, 4), ROW(5, 6)) AS t1 (foo, bar)
OFFSET 1 ROW;
-- FOO: 3 BAR: 4
-- FOO: 5 BAR: 6

SELECT * FROM (VALUES ROW(1, 2), ROW(3, 4), ROW(5, 6)) AS t1 (foo, bar)
OFFSET 10 ROWS;
