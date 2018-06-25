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


# Start Reliable Connection in Reliable Environment
rebootServer
startApplication

echo "done starting application, starting stress session"
# Reliable WS
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket_ping --messages=240 --interval=500 --concurrent=1 --optional=DateTimeWSReliable --protocol=websocket --repeat=15

rebootServer
startApplication

# Reliable Ordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=240 --interval=500 --ordered=false  --concurrent=1 --optional=DateTimeDCReliable --protocol=datachannel --repeat=15

echo "Done for 'reliable connection in reliable environment'"
# End

# Start Unreliable Connection in Reliable Environment
rebootServer
startApplication

# Unreliable RTX Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket_ping --messages=480 --interval=250 --concurrent=1 --optional=DateTimeWSReliableDouble --protocol=websocket --repeat=15

# Start Unreliable Connection in Reliable Environment
rebootServer
startApplication

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false  --concurrent=1 --optional=DateTimeDCReliableDouble --protocol=datachannel --repeat=15


echo "Done for 'unreliable connection in unreliable environment'"
# End
