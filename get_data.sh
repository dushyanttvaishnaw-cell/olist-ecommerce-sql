#!/usr/bin/env bash
# Pulls the Olist CSVs into data/. Same files as the Kaggle dataset
# (olistbr/brazilian-ecommerce), straight from Olist's own GitHub repo.
set -e
mkdir -p data
BASE=https://raw.githubusercontent.com/olist/work-at-olist-data/master/datasets
for f in customers sellers products orders order_items order_payments order_reviews; do
  echo "olist_${f}_dataset.csv"
  curl -sSfL -o "data/olist_${f}_dataset.csv" "$BASE/olist_${f}_dataset.csv"
done
curl -sSfL -o data/product_category_name_translation.csv "$BASE/product_category_name_translation.csv"
echo done
