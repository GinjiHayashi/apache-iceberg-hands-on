-- 06. 追加目標（任意）: Trino の add_files（1/2 テーブルを作る）
-- 実行: make trino-sql FILE=handson/06_parquet_conversion/trino_add_files_1_create.sql
-- この後、README の手順で S3 ブラウザ（s3manager）から Parquet をアップロードし、2/2 を実行する。
--
-- Trino は中身のある場所にはテーブルを作れないので、アップロードより先にテーブルを作る。
-- やり直すときは、README の「やり直すとき」の手順で片付けてから、このファイルから実行する。

-- Parquet と同じ列を持つテーブルを、場所を指定して作る
-- （add_files で登録するファイルは、この場所の下に置く。Polaris が払い出す認証情報はテーブルの場所の下にしか届かないため）
CREATE TABLE taxi_trino_addfiles (
    VendorID               INTEGER,
    tpep_pickup_datetime   TIMESTAMP(6),
    tpep_dropoff_datetime  TIMESTAMP(6),
    passenger_count        BIGINT,
    trip_distance          DOUBLE,
    RatecodeID             BIGINT,
    store_and_fwd_flag     VARCHAR,
    PULocationID           INTEGER,
    DOLocationID           INTEGER,
    payment_type           BIGINT,
    fare_amount            DOUBLE,
    extra                  DOUBLE,
    mta_tax                DOUBLE,
    tip_amount             DOUBLE,
    tolls_amount           DOUBLE,
    improvement_surcharge  DOUBLE,
    total_amount           DOUBLE,
    congestion_surcharge   DOUBLE,
    Airport_fee            DOUBLE
)
WITH (location = 's3://warehouse/handson/taxi_trino_addfiles');

