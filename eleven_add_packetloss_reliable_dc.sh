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

# Start Reliable Connection in Reliable Environment
rebootServer
startApplication

echo "done starting application, starting stress session"
# Reliable WS
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket_ping --messages=480 --interval=250 --concurrent=1 --optional=EleventhRoundReliableWS --protocol=websocket --repeat=15

# Start Unreliable Connection in Reliable Environment
rebootServer
startApplication

# Unreliable RTX Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false --concurrent=1 --optional=EleventhRoundReliableDC --protocol=datachannel --repeat=15

rebootServer
startApplication

# Unreliable RTO Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=true --concurrent=1 --optional=EleventhRoundReliableDC --protocol=datachannel --repeat=15

# End

# Start Unreliable connection in unreliable environment 2.5% Both
rebootServer
startApplication
setPacketLoss 2.5%

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket_ping --messages=480 --interval=250 --concurrent=1 --optional=EleventhRoundReliableWS2.5% --protocol=websocket --repeat=15

rebootServer
startApplication
setPacketLoss 2.5%

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false --concurrent=1 --optional=EleventhRoundReliableDC2.5 --protocol=datachannel --repeat=15

# Unreliable RTX Unordered DC

rebootServer
startApplication
setPacketLoss 2.5%

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=true --concurrent=1 --optional=EleventhRoundReliableDC2.5 --protocol=datachannel --repeat=15

# Start Unreliable connection in unreliable environment 2.5% Both
rebootServer
startApplication
setPacketLoss 5.0%

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket_ping --messages=480 --interval=250 --concurrent=1 --optional=EleventhRoundReliableWS5.0% --protocol=websocket --repeat=15

rebootServer
startApplication
setPacketLoss 5.0%

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false --concurrent=1 --optional=EleventhRoundReliableDC5.0 --protocol=datachannel --repeat=15

# Unreliable RTX Unordered DC

rebootServer
startApplication
setPacketLoss 5.0%

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=true --concurrent=1 --optional=EleventhRoundReliableDC5.0 --protocol=datachannel --repeat=15

# Start Reliable Connection in Reliable Environment
rebootServer
startApplication

echo "done starting application, starting stress session"
# Reliable WS
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket_ping --messages=480 --interval=250 --concurrent=1 --optional=EleventhRoundReliableWS --protocol=websocket --repeat=15 --message-size=250

# Start Unreliable Connection in Reliable Environment
rebootServer
startApplication

# Unreliable RTX Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false --concurrent=1 --optional=EleventhRoundReliableDC --protocol=datachannel --repeat=15 --message-size=250

rebootServer
startApplication

# Unreliable RTO Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=true --concurrent=1 --optional=EleventhRoundReliableDC --protocol=datachannel --repeat=15 --message-size=250

# End

# Start Unreliable connection in unreliable environment 2.5% Both
rebootServer
startApplication
setPacketLoss 2.5%

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket_ping --messages=480 --interval=250 --concurrent=1 --optional=EleventhRoundReliableWS2.5% --protocol=websocket --repeat=15 --message-size=250

rebootServer
startApplication
setPacketLoss 2.5%

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false --concurrent=1 --optional=EleventhRoundReliableDC2.5 --protocol=datachannel --repeat=15 --message-size=250

# Unreliable RTX Unordered DC

rebootServer
startApplication
setPacketLoss 2.5%

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=true --concurrent=1 --optional=EleventhRoundReliableDC2.5 --protocol=datachannel --repeat=15 --message-size=250

# Start Unreliable connection in unreliable environment 2.5% Both
rebootServer
startApplication
setPacketLoss 5.0%

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket_ping --messages=480 --interval=250 --concurrent=1 --optional=EleventhRoundReliableWS5.0% --protocol=websocket --repeat=15 --message-size=250

rebootServer
startApplication
setPacketLoss 5.0%

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false --concurrent=1 --optional=EleventhRoundReliableDC5.0 --protocol=datachannel --repeat=15 --message-size=250

# Unreliable RTX Unordered DC

rebootServer
startApplication
setPacketLoss 5.0%

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=true --concurrent=1 --optional=EleventhRoundReliableDC5.0 --protocol=datachannel --repeat=15 --message-size=250

# Start Reliable Connection in Reliable Environment
rebootServer
startApplication

echo "done starting application, starting stress session"
# Reliable WS
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket_ping --messages=120 --interval=1000 --concurrent=1 --optional=EleventhRoundReliableWS --protocol=websocket --repeat=15

# Start Unreliable Connection in Reliable Environment
rebootServer
startApplication

# Unreliable RTX Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=120 --interval=1000 --ordered=false --concurrent=1 --optional=EleventhRoundReliableDC --protocol=datachannel --repeat=15

rebootServer
startApplication

# Unreliable RTO Unordered DC
node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=120 --interval=1000 --ordered=true --concurrent=1 --optional=EleventhRoundReliableDC --protocol=datachannel --repeat=15

# End

# Start Unreliable connection in unreliable environment 2.5% Both
rebootServer
startApplication
setPacketLoss 2.5%

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket_ping --messages=120 --interval=1000 --concurrent=1 --optional=EleventhRoundReliableWS2.5% --protocol=websocket --repeat=15

rebootServer
startApplication
setPacketLoss 2.5%

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=120 --interval=1000 --ordered=false --concurrent=1 --optional=EleventhRoundReliableDC2.5 --protocol=datachannel --repeat=15

# Unreliable RTX Unordered DC

rebootServer
startApplication
setPacketLoss 2.5%

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=120 --interval=1000 --ordered=true --concurrent=1 --optional=EleventhRoundReliableDC2.5 --protocol=datachannel --repeat=15

# Start Unreliable connection in unreliable environment 2.5% Both
rebootServer
startApplication
setPacketLoss 5.0%

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket_ping --messages=120 --interval=1000 --concurrent=1 --optional=EleventhRoundReliableWS5.0% --protocol=websocket --repeat=15

rebootServer
startApplication
setPacketLoss 5.0%

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=120 --interval=1000 --ordered=false --concurrent=1 --optional=EleventhRoundReliableDC5.0 --protocol=datachannel --repeat=15

# Unreliable RTX Unordered DC

rebootServer
startApplication
setPacketLoss 5.0%

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=120 --interval=1000 --ordered=true --concurrent=1 --optional=EleventhRoundReliableDC5.0 --protocol=datachannel --repeat=15
