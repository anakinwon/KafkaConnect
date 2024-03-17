log_suffix=`date +"%Y%m%d%H%M%S"`
/home/anakin/confluent/bin/connect-distributed /home/anakin/confluent/etc/kafka/connect-distributed.properties 2>&1 | tee -a ~/connect_console_log/connect_console_$log_suffix.log
