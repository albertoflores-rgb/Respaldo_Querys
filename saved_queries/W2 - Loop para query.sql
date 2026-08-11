DECLARE current_iteration INT64 DEFAULT 0;

CREATE TEMP TABLE TestCTE AS
SELECT 1 AS n, current_iteration AS iteration;

REPEAT
SET current_iteration = current_iteration + 1;

INSERT INTO TestCTE
SELECT n + 3, current_iteration
FROM TestCTE
WHERE
  MOD(n, 6) != 0
  AND iteration = current_iteration - 1
  AND current_iteration < 10;

UNTIL
  NOT EXISTS(SELECT * FROM TestCTE WHERE iteration = current_iteration)
    END REPEAT;

-- Print the number of rows produced by each iteration

SELECT iteration, COUNT(1) AS num_rows
FROM TestCTE
GROUP BY iteration
ORDER BY iteration;

-- Examine the actual result produced for a specific iteration

SELECT * FROM TestCTE WHERE iteration = 2;