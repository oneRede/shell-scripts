curl -X POST https://api.anysearch.com/v1/search \
  -H "Authorization: Bearer as_sk_3c38026829b6b3bf9d1702d008f5fc1a" \
  -H "Content-Type: application/json" \
  -d '{
        "query": "黄金最新价格",
        "max_results": 5
      }'  