#!/usr/bin/env bash
# Requires env var of dir, KAGGLE_LOC
# Requires Kaggle API, Google Cloud SDK

print '=== Downloading from Kaggle... ==='
kaggle competitions download \
  -c grupo-bimbo-inventory-demand \
  -p $KAGGLE_LOC

print '=== Unzipping all...  ==='
cd $KAGGLE_LOC
for z in $KAGGLE_LOC/*.zip; do unzip $z; done
rm *.zip

print '=== Creating BigQuery Dataset... ==='
bq --location=US mk -d --default_table_expiration 3600 --description grupo_bimbo

print '=== Shipping off CSVs to bq... ==='
for f in *.csv; do
  print '=== Working ${f}... ==='
  table=${f%%.*}
  bq --location=US load --autodetect --replace --source_format=CSV grupo_bimbo.$table $f
  rm $f
done
