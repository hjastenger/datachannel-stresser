rebootServer() {
	echo "Rebooting server."
 	ssh -t -i ~/.ssh_do root@167.99.36.97 "source /etc/profile; tmux send-keys -t application 'C-c' Enter; reboot"
	sleep 30s
}

startApplication() {
	echo "Starting application"
	ssh -t -i ~/.ssh_do root@167.99.36.97 "source /etc/profile;. /root/scripts/start_tmux.sh"
	sleep 30s
}

setPacketLoss() {
	echo "Setting packet loss"
	ssh -t -i ~/.ssh_do root@167.99.36.97 "source /etc/profile;. /root/scripts/set_packet_loss.sh \"$1\""
}

rebootServer
startApplication

echo "done starting application, starting stress session"
# Reliable WS
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket_ping --messages=480 --interval=250 --concurrent=5 --optional=SixteenthRoundReliableWS --protocol=websocket --repeat=15

rebootServer
startApplication

echo "done starting application, starting stress session"
# Reliable DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --concurrent=5 --ordered=true --optional=SixteenthRoundReliableDC --protocol=datachannel --repeat=15

rebootServer
startApplication

echo "done starting application, starting stress session"
# Reliable DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --concurrent=5 --ordered=false --optional=SixteenthRoundReliableDC --protocol=datachannel --repeat=15

# Start Unreliable Connection in Reliable Environment
rebootServer
startApplication

# Unreliable RTX Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false  --retransmit-times=0 --concurrent=5 --optional=SixteenthRoundUnreliableDC --protocol=datachannel --repeat=15

rebootServer
startApplication

# Unreliable RTO Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false  --retransmit-timeout=1 --concurrent=5 --optional=SixteenthRoundUnreliableDC --protocol=datachannel --repeat=15

# End

# Start Unreliable connection in unreliable environment 2.5% Both
rebootServer
startApplication
setPacketLoss 2.5%

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket_ping --messages=480 --interval=250 --concurrent=5 --optional=SixteenthRoundReliableWS2.5% --protocol=websocket --repeat=15

rebootServer
startApplication
setPacketLoss 2.5%

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false  --concurrent=5 --optional=SixteenthRoundReliableDC2.5 --protocol=datachannel --repeat=15

rebootServer
startApplication
setPacketLoss 2.5%

# Unreliable RTO Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=true --concurrent=5 --optional=SixteenthRoundReliableDC2.5 --protocol=datachannel --repeat=15

rebootServer
startApplication
setPacketLoss 2.5%

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false  --retransmit-times=0 --concurrent=5 --optional=SixteenthRoundUnreliableDC2.5 --protocol=datachannel --repeat=15

rebootServer
startApplication
setPacketLoss 2.5%

# Unreliable RTX Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false  --retransmit-times=1 --concurrent=5 --optional=SixteenthRoundUnreliableDC2.5 --protocol=datachannel --repeat=15

rebootServer
startApplication
setPacketLoss 2.5%

# Unreliable RTX Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false  --retransmit-times=2 --concurrent=5 --optional=SixteenthRoundUnreliableDC2.5 --protocol=datachannel --repeat=15

rebootServer
startApplication
setPacketLoss 2.5%

# Unreliable RTO Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false  --retransmit-timeout=1 --concurrent=5 --optional=SixteenthRoundUnreliableDC2.5 --protocol=datachannel --repeat=15

rebootServer
startApplication
setPacketLoss 2.5%

# Unreliable RTO Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false  --retransmit-timeout=500 --concurrent=5 --optional=SixteenthRoundUnreliableDC2.5 --protocol=datachannel --repeat=15

rebootServer
startApplication
setPacketLoss 2.5%

# Unreliable RTO Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false  --retransmit-timeout=1000 --concurrent=5 --optional=SixteenthRoundUnreliableDC2.5 --protocol=datachannel --repeat=15

echo "Done for 'unreliable connection in unreliable environment'"
# End

# Start Unreliable connection in unreliable environment 5.0% Both

rebootServer
startApplication
setPacketLoss 5.0%

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket_ping --messages=480 --interval=250 --concurrent=5 --optional=SixteenthRoundReliableWS5.0% --protocol=websocket --repeat=15

rebootServer
startApplication
setPacketLoss 5.0%

# Unreliable RTX Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false  --concurrent=5 --optional=SixteenthRoundReliableDC5.0 --protocol=datachannel --repeat=15

rebootServer
startApplication
setPacketLoss 5.0%

# Unreliable RTX Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=true  --concurrent=5 --optional=SixteenthRoundReliableDC5.0 --protocol=datachannel --repeat=15

rebootServer
startApplication
setPacketLoss 5.0%

# Unreliable RTX Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false  --retransmit-times=0 --concurrent=5 --optional=SixteenthRoundUnreliableDC5.0 --protocol=datachannel --repeat=15

rebootServer
startApplication
setPacketLoss 5.0%

# Unreliable RTX Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false  --retransmit-times=1 --concurrent=5 --optional=SixteenthRoundUnreliableDC5.0 --protocol=datachannel --repeat=15

rebootServer
startApplication
setPacketLoss 5.0%

# Unreliable RTX Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false  --retransmit-times=2 --concurrent=5 --optional=SixteenthRoundUnreliableDC5.0 --protocol=datachannel --repeat=15

rebootServer
startApplication
setPacketLoss 5.0%

# Unreliable RTO Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false  --retransmit-timeout=1 --concurrent=5 --optional=SixteenthRoundUnreliableDC5.0 --protocol=datachannel --repeat=15

rebootServer
startApplication
setPacketLoss 5.0%

# Unreliable RTO Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false  --retransmit-timeout=500 --concurrent=5 --optional=SixteenthRoundUnreliableDC5.0 --protocol=datachannel --repeat=15

rebootServer
startApplication
setPacketLoss 5.0%

# Unreliable RTO Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false  --retransmit-timeout=1000 --concurrent=5 --optional=SixteenthRoundUnreliableDC5.0 --protocol=datachannel --repeat=15
