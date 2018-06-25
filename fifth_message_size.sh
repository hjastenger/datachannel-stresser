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
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket_ping --messages=480 --interval=500 --concurrent=1 --optional=FifthRoundReliableWS --protocol=websocket --repeat=15 --message-size=5000

rebootServer
startApplication

# Reliable Ordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=500 --ordered=false  --concurrent=1 --optional=FifthRoundReliableDC --protocol=datachannel --repeat=15 --message-size=5000

echo "Done for 'reliable connection in reliable environment'"
# End

# Start Unreliable Connection in Reliable Environment
rebootServer
startApplication

# Unreliable RTX Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=500 --ordered=false  --retransmit-times=0 --concurrent=1 --optional=FifthRoundUnreliableDC --protocol=datachannel --repeat=15 --message-size=5000

rebootServer
startApplication

# Unreliable RTO Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=500 --ordered=false  --retransmit-timeout=0 --concurrent=1 --optional=FifthRoundUnreliableDC --protocol=datachannel --repeat=15 --message-size=5000

echo "Done for 'unreliable connection in reliable environment'"
# End

# Start Unreliable connection in unreliable environment 2.5% Both
rebootServer
startApplication
setPacketLoss 2.5%

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket_ping --messages=480 --interval=500 --concurrent=1 --optional=FifthRoundReliableWS2.5% --protocol=websocket --repeat=15 --message-size=5000

# Unreliable RTX Unordered DC

rebootServer
startApplication
setPacketLoss 2.5%

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=500 --ordered=false  --retransmit-times=0 --concurrent=1 --optional=FifthRoundUnreliableDC2.5 --protocol=datachannel --repeat=15 --message-size=5000

rebootServer
startApplication
setPacketLoss 2.5%

# Unreliable RTX Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=500 --ordered=false  --retransmit-times=1 --concurrent=1 --optional=FifthRoundUnreliableDC2.5 --protocol=datachannel --repeat=15 --message-size=5000

rebootServer
startApplication
setPacketLoss 2.5%

# Unreliable RTX Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=500 --ordered=false  --retransmit-times=2 --concurrent=1 --optional=FifthRoundUnreliableDC2.5 --protocol=datachannel --repeat=15 --message-size=5000

rebootServer
startApplication
setPacketLoss 2.5%

# Unreliable RTO Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=500 --ordered=false  --retransmit-timeout=0 --concurrent=1 --optional=FifthRoundUnreliableDC2.5 --protocol=datachannel --repeat=15 --message-size=5000

rebootServer
startApplication
setPacketLoss 2.5%

# Unreliable RTO Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=500 --ordered=false  --retransmit-timeout=500 --concurrent=1 --optional=FifthRoundUnreliableDC2.5 --protocol=datachannel --repeat=15 --message-size=5000

rebootServer
startApplication
setPacketLoss 2.5%

# Unreliable RTO Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=500 --ordered=false  --retransmit-timeout=1000 --concurrent=1 --optional=FifthRoundUnreliableDC2.5 --protocol=datachannel --repeat=15 --message-size=5000

echo "Done for 'unreliable connection in unreliable environment'"
# End

# Start Unreliable connection in unreliable environment 5.0% Both

rebootServer
startApplication
setPacketLoss 5.0%

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket_ping --messages=480 --interval=500 --concurrent=1 --optional=FifthRoundReliableWS5.0% --protocol=websocket --repeat=15 --message-size=5000

rebootServer
startApplication
setPacketLoss 5.0%

# Unreliable RTX Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=500 --ordered=false  --retransmit-times=0 --concurrent=1 --optional=FifthRoundUnreliableDC5.0 --protocol=datachannel --repeat=15 --message-size=5000

rebootServer
startApplication
setPacketLoss 5.0%

# Unreliable RTX Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=500 --ordered=false  --retransmit-times=1 --concurrent=1 --optional=FifthRoundUnreliableDC5.0 --protocol=datachannel --repeat=15 --message-size=5000

rebootServer
startApplication
setPacketLoss 5.0%

# Unreliable RTX Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=500 --ordered=false  --retransmit-times=2 --concurrent=1 --optional=FifthRoundUnreliableDC5.0 --protocol=datachannel --repeat=15 --message-size=5000

rebootServer
startApplication
setPacketLoss 5.0%

# Unreliable RTO Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=500 --ordered=false  --retransmit-timeout=0 --concurrent=1 --optional=FifthRoundUnreliableDC5.0 --protocol=datachannel --repeat=15 --message-size=5000

rebootServer
startApplication
setPacketLoss 5.0%

# Unreliable RTO Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=500 --ordered=false  --retransmit-timeout=500 --concurrent=1 --optional=FifthRoundUnreliableDC5.0 --protocol=datachannel --repeat=15 --message-size=5000

rebootServer
startApplication
setPacketLoss 5.0%

# Unreliable RTO Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=500 --ordered=false  --retransmit-timeout=1000 --concurrent=1 --optional=FifthRoundUnreliableDC5.0 --protocol=datachannel --repeat=15 --message-size=5000

echo "Done for 'unreliable connection in unreliable environment'"
# End
