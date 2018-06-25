rebootServer() {
	echo "Rebooting server."
 	ssh -t -i ~/.ssh_do root@167.99.36.97 "source /etc/profile; tmux send-keys -t application 'C-c' Enter; reboot"
	sleep 1m
}

startApplication() {
	echo "Starting application"
	ssh -t -i ~/.ssh_do root@167.99.36.97 "source /etc/profile;. /root/scripts/start_tmux.sh"
	sleep 1m
}

setPacketLoss() {
	echo "Setting packet loss"
	ssh -t -i ~/.ssh_do root@167.99.36.97 "source /etc/profile;. /root/scripts/set_packet_loss.sh \"$1\""
}

setOutboundLoss() {
	echo "Setting packet loss"
	ssh -t -i ~/.ssh_do root@167.99.36.97 "source /etc/profile;. /root/scripts/set_outbound_loss.sh \"$1\""
}

setInboundLoss() {
	echo "Setting packet loss"
	ssh -t -i ~/.ssh_do root@167.99.36.97 "source /etc/profile;. /root/scripts/set_inbound_loss.sh \"$1\""
}

# Inbound retransmitTimes

rebootServer
setInboundLoss 2.5%
startApplication

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=500 --ordered=false  --retransmit-timeout=0 --concurrent=1 --optional=SecondRoundUnreliableDC2.5Inbound --protocol=datachannel --repeat=2

rebootServer
setInboundLoss 2.5%
startApplication

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=500 --ordered=false  --retransmit-timeout=1 --concurrent=1 --optional=SecondRoundUnreliableDC2.5Inbound --protocol=datachannel --repeat=2

rebootServer
setInboundLoss 2.5%
startApplication

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=500 --ordered=false  --retransmit-timeout=2 --concurrent=1 --optional=SecondRoundUnreliableDC2.5Inbound --protocol=datachannel --repeat=2
