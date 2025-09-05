1. Source인 오라클은 테이블&컬럼이 대문자이고,
   Target인 Postgres 테이블&컬럼이 소문자일 경우 아래와 같이 주의할 것.

2. TIMEZONE도 아래와 같이 주의 할 것!


        "transforms": "lowercaseKey,lowercaseValue,convertTimestamp",
        "transforms.lowercaseKey.type": "org.apache.kafka.connect.transforms.ReplaceField$Key",
        "transforms.lowercaseKey.renames": "ORDER_ID:order_id",
        "transforms.lowercaseValue.type": "org.apache.kafka.connect.transforms.ReplaceField$Value",
        "transforms.lowercaseValue.renames": "ORDER_ID:order_id,ORDER_DATETIME:order_datetime,CUSTOMER_ID:customer_id,ORDER_STATUS:order_status,STORE_ID:store_id",

        "transforms.convertTimestamp.type": "org.apache.kafka.connect.transforms.TimestampConverter$Value",
        "transforms.convertTimestamp.field": "order_datetime",
        "transforms.convertTimestamp.target.type": "Timestamp"
