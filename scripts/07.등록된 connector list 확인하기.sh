### Connector 클래스의 plugin.path 로딩 확인.

- curl 과  jq 설치
```bash
sudo apt-get install curl
sudo apt-get install jq

```

### httpie를 이용하여 REST API 호출

- httpie 설치
```sql
sudo apt-get install httpie

```

- connector 리스트 확인
```sql
http GET http://localhost:8083/connectors

```





- 재 기동 후 아래 curl 명령어로 Connector가 제대로 Connect로 로딩 되었는지 확인

```bash
curl -X GET -H "Content-Type: application/json" http://localhost:8083/connector-plugins  | jq '.'

```

- Connect를 재기동하고 REST API로 해당 plugin class가 제대로 Connect에 로딩 되었는지 확인

```sql
# 아래 명령어는 반드시 Connect를 재 기동후 수행
http http://localhost:8083/connector-plugins

http http://localhost:8083/connector-plugins | jq '.[].class'

```