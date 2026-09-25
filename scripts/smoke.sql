-- 動作確認: テーブルを作り、書き込み、読み出して、片付ける
CREATE TABLE IF NOT EXISTS smoke_test (id INTEGER, message VARCHAR);
INSERT INTO smoke_test VALUES (1, 'hello'), (2, 'iceberg');
SELECT count(*) AS row_count FROM smoke_test;
DROP TABLE smoke_test;
