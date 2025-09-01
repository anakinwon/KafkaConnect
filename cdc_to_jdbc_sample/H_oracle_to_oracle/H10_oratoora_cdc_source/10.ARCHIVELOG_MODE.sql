즉, 오라클이 NOARCHIVELOG 모드라서 redo log 를 CDC 추적용으로 못 쓰고 있어요.
Debezium Oracle Connector는 ARCHIVELOG 모드 + Supplemental Logging 이 반드시 필요합니다.

✅ 해결 방법 (Oracle DB 설정)

    아래 절차대로 오라클 DB에서 설정하세요.
    현재 로그 모드 확인

        sql> SELECT LOG_MODE FROM V$DATABASE;

    👉 NOARCHIVELOG 라고 나올 겁니다.

    <DB 종료>
        sql> sqlplus / as sysdba
        sql> SHUTDOWN IMMEDIATE;

    Mount 모드로 시작
        sql> STARTUP MOUNT;

    ARCHIVELOG 모드로 전환
        sql> ALTER DATABASE ARCHIVELOG;

    DB 오픈
        sql> ALTER DATABASE OPEN;

    결과 확인
        sql> ELECT LOG_MODE FROM V$DATABASE;


    👉 ARCHIVELOG 로 나와야 정상입니다.

✅ Supplemental Logging 활성화 (Debezium 필수)

    Redo log 안에 변경된 데이터를 제대로 기록하려면 보조 로깅을 켜야 합니다.

        sql> ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;
        sql> ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;

🔄 Connector 재시작

이제 Kafka Connect에서 Oracle Debezium Connector를 다시 시작하면 정상 동작합니다.

👉 지금 사용하시는 오라클이 로컬 개발용 Docker/VM인가요, 아니면 운영 서버인가요?
운영 서버라면 ARCHIVELOG 전환 전에 백업 정책도 같이 확인하셔야 합니다.