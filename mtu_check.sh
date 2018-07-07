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


# Start Reliable Connection in Reliable Environment
rebootServer
setOutboundLoss 2.5%
startApplication

# Reliable Ordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=240 --interval=500 --ordered=false  --retransmits=0 --concurrent=1 --optional=MTUCheckOutbound --protocol=datachannel --repeat=15 --message-size=250

# Start Reliable Connection in Reliable Environment
rebootServer
setInboundLoss 2.5%
startApplication

# Reliable Ordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=240 --interval=500 --ordered=false  --retransmits=0 --concurrent=1 --optional=MTUCheckInbound --protocol=datachannel --repeat=15 --message-size=250
