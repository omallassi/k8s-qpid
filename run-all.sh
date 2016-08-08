export BROKERS_IP=(172.17.0.4 172.17.0.5) # TODO ask k8s


for i in ${BROKERS_IP[@]}; do
	curl -v --user admin:admin -H 'Content-Type: application/json' -X PUT -d '{"type":"Memory", "name":"thisIsIt","queue.deadLetterQueueEnabled":true}' http://$i:8080/api/latest/virtualhost/default/thisIsIt
	curl -v --user admin:admin -H 'Content-Type: application/json' -X PUT -d '{"type":"topic","name":"payments"}' http://$i:8080/api/latest/exchange/default/thisIsIt/payments
	curl -v --user admin:admin -H 'Content-Type: application/json' -X PUT -d '{"type":"standard", "name":"instruction"}' http://$i:8080/api/latest/queue/default/thisIsIt/instruction
	curl -v --user admin:admin -H 'Content-Type: application/json' -X POST -d '{"name":"payments.*","exchange":"payments", "queue":"instruction", "arguments": {"x-filter-jms-selector": "color=\u0027blue\u0027"}}' http://$i:8080/api/latest/binding/default/thisIsIt/payments/instruction/
done


#configure the router (to create a new waypoint)
#qdmanage -b 192.168.56.102:20000 create --type=waypoint inPhase=0 connector=broker.11000 outPhase=1 address=workflow