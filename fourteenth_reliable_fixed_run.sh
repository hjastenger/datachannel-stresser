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

# START MSG INTERVAL/RTATE EXPERIMENTS

# msg={120} round 0.0
# rebootServer
# startApplication

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=120 --interval=1000 --ordered=false --concurrent=1 --optional=TenthRoundReliableDC --protocol=datachannel --repeat=15

# rebootServer
# startApplication

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=120 --interval=1000 --ordered=true --concurrent=1 --optional=TenthRoundReliableDC --protocol=datachannel --repeat=15

# # msg={120} round 2.5
# rebootServer
# startApplication
# setPacketLoss 2.5%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=120 --interval=1000 --ordered=false --concurrent=1 --optional=TenthRoundReliableDC2.5 --protocol=datachannel --repeat=15

# rebootServer
# startApplication
# setPacketLoss 2.5%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=120 --interval=1000 --ordered=true --concurrent=1 --optional=TenthRoundReliableDC2.5 --protocol=datachannel --repeat=15

# # msg={120} round 5.0
# rebootServer
# startApplication
# setPacketLoss 5.0%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=120 --interval=1000 --ordered=false --concurrent=1 --optional=TenthRoundReliableDC5.0 --protocol=datachannel --repeat=15

# rebootServer
# startApplication
# setPacketLoss 5.0%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=120 --interval=1000 --ordered=true --concurrent=1 --optional=TenthRoundReliableDC5.0 --protocol=datachannel --repeat=15

# # END

# # msg={240} round 0.0
# # Already done.
# # rebootServer
# # startApplication

# # node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=240 --interval=500 --ordered=false --concurrent=1 --optional=SeventhRoundReliableDC --protocol=datachannel --repeat=15

# rebootServer
# startApplication

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=240 --interval=500 --ordered=true --concurrent=1 --optional=SeventhRoundReliableDC --protocol=datachannel --repeat=15

# # msg={240} round 2.5
# rebootServer
# startApplication
# setPacketLoss 2.5%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=240 --interval=500 --ordered=false --concurrent=1 --optional=SeventhRoundReliableDC2.5 --protocol=datachannel --repeat=15

# rebootServer
# startApplication
# setPacketLoss 2.5%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=240 --interval=500 --ordered=true --concurrent=1 --optional=SeventhRoundReliableDC2.5 --protocol=datachannel --repeat=15

# # msg={240} round 5.0
# rebootServer
# startApplication
# setPacketLoss 5.0%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=240 --interval=500 --ordered=false --concurrent=1 --optional=SeventhRoundReliableDC5.0 --protocol=datachannel --repeat=15

# rebootServer
# startApplication
# setPacketLoss 5.0%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=240 --interval=500 --ordered=true --concurrent=1 --optional=SeventhRoundReliableDC5.0 --protocol=datachannel --repeat=15

# # END

# # msg={480} round 0.0
# # rebootServer
# # startApplication

# # Already done
# # node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false --concurrent=1 --optional=SixthRoundReliableDC --protocol=datachannel --repeat=15

# # rebootServer
# # startApplication

# # Already done
# # node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=true --concurrent=1 --optional=SixthRoundReliableDC --protocol=datachannel --repeat=15

# # msg={480} round 2.5
# rebootServer
# startApplication
# setPacketLoss 2.5%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false --concurrent=1 --optional=SixthRoundReliableDC2.5 --protocol=datachannel --repeat=15

# rebootServer
# startApplication
# setPacketLoss 2.5%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=true --concurrent=1 --optional=SixthRoundReliableDC2.5 --protocol=datachannel --repeat=15

# # msg={480} round 5.0
# rebootServer
# startApplication
# setPacketLoss 5.0%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false --concurrent=1 --optional=SixthRoundReliableDC5.0 --protocol=datachannel --repeat=15

# rebootServer
# startApplication
# setPacketLoss 5.0%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=true --concurrent=1 --optional=SixthRoundReliableDC5.0 --protocol=datachannel --repeat=15

# # END

# # msg={960} round 0.0
# rebootServer
# startApplication

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=960 --interval=125 --ordered=false --concurrent=1 --optional=EighthRoundReliableDC --protocol=datachannel --repeat=15

# rebootServer
# startApplication

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=960 --interval=125 --ordered=true --concurrent=1 --optional=EighthRoundReliableDC --protocol=datachannel --repeat=15

# # msg={960} round 2.5
# rebootServer
# startApplication
# setPacketLoss 2.5%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=960 --interval=125 --ordered=false --concurrent=1 --optional=EighthRoundReliableDC2.5 --protocol=datachannel --repeat=15

# rebootServer
# startApplication
# setPacketLoss 2.5%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=960 --interval=125 --ordered=true --concurrent=1 --optional=EighthRoundReliableDC2.5 --protocol=datachannel --repeat=15

# # msg={960} round 5.0
# rebootServer
# startApplication
# setPacketLoss 5.0%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=960 --interval=125 --ordered=false --concurrent=1 --optional=EighthRoundReliableDC5.0 --protocol=datachannel --repeat=15

# rebootServer
# startApplication
# setPacketLoss 5.0%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=960 --interval=125 --ordered=true --concurrent=1 --optional=EighthRoundReliableDC5.0 --protocol=datachannel --repeat=15

# # END

# # msg={1600} round 0.0
# rebootServer
# startApplication

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=1600 --interval=75 --ordered=false --concurrent=1 --optional=NinthRoundReliableDC --protocol=datachannel --repeat=15

# rebootServer
# startApplication

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=1600 --interval=75 --ordered=true --concurrent=1 --optional=NinthRoundReliableDC --protocol=datachannel --repeat=15

# # msg={1600} round 2.5
# rebootServer
# startApplication
# setPacketLoss 2.5%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=1600 --interval=75 --ordered=false --concurrent=1 --optional=NinthRoundReliableDC2.5 --protocol=datachannel --repeat=15

# rebootServer
# startApplication
# setPacketLoss 2.5%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=1600 --interval=75 --ordered=true --concurrent=1 --optional=NinthRoundReliableDC2.5 --protocol=datachannel --repeat=15

# # msg={1600} round 5.0
# rebootServer
# startApplication
# setPacketLoss 5.0%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=1600 --interval=75 --ordered=false --concurrent=1 --optional=NinthRoundReliableDC5.0 --protocol=datachannel --repeat=15

# rebootServer
# startApplication
# setPacketLoss 5.0%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=1600 --interval=75 --ordered=true --concurrent=1 --optional=NinthRoundReliableDC5.0 --protocol=datachannel --repeat=15

# # END

# # START MSG SIZE EXPERIMENTS

# # size={0} round 0.0
# # rebootServer
# # startApplication

# # node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false --concurrent=1 --optional=NinthRoundReliableDC --protocol=datachannel --repeat=15

# # rebootServer
# # startApplication

# # node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=1600 --interval=75 --ordered=true --concurrent=1 --optional=NinthRoundReliableDC --protocol=datachannel --repeat=15

# # size={0} round 2.5
# rebootServer
# startApplication
# setPacketLoss 2.5%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false --concurrent=1 --optional=SixthRoundReliableDC2.5 --protocol=datachannel --repeat=15

# rebootServer
# startApplication
# setPacketLoss 2.5%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=true --concurrent=1 --optional=SixthRoundReliableDC2.5 --protocol=datachannel --repeat=15

# # size={0} round 5.0
# rebootServer
# startApplication
# setPacketLoss 5.0%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false --concurrent=1 --optional=SixthRoundReliableDC5.0 --protocol=datachannel --repeat=15

# rebootServer
# startApplication
# setPacketLoss 5.0%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=true --concurrent=1 --optional=SixthRoundReliableDC5.0 --protocol=datachannel --repeat=15

# # END

# # size={250} round 0.0
# # rebootServer
# # startApplication

# # node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false --concurrent=1 --optional=NinthRoundReliableDC --protocol=datachannel --repeat=15

# rebootServer
# startApplication

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=true --concurrent=1 --optional=TwelfthRoundReliableDC --protocol=datachannel --repeat=15 --message-size=250

# # size={0} round 2.5
# rebootServer
# startApplication
# setPacketLoss 2.5%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false --concurrent=1 --optional=TwelfthRoundReliableDC2.5 --protocol=datachannel --repeat=15 --message-size=250

# rebootServer
# startApplication
# setPacketLoss 2.5%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=true --concurrent=1 --optional=TwelfthRoundReliableDC2.5 --protocol=datachannel --repeat=15 --message-size=250

# # size={0} round 5.0
# rebootServer
# startApplication
# setPacketLoss 5.0%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false --concurrent=1 --optional=TwelfthRoundReliableDC5.0 --protocol=datachannel --repeat=15 --message-size=250

# rebootServer
# startApplication
# setPacketLoss 5.0%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=true --concurrent=1 --optional=TwelfthRoundReliableDC5.0 --protocol=datachannel --repeat=15 --message-size=250

# # END

# # size={500} round 0.0
# # rebootServer
# # startApplication

# # node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false --concurrent=1 --optional=NinthRoundReliableDC --protocol=datachannel --repeat=15

# rebootServer
# startApplication

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=true --concurrent=1 --optional=TenthRoundReliableDC --protocol=datachannel --repeat=15 --message-size=500

# # size={500} round 2.5
# rebootServer
# startApplication
# setPacketLoss 2.5%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false --concurrent=1 --optional=TenthRoundReliableDC2.5 --protocol=datachannel --repeat=15 --message-size=500

# rebootServer
# startApplication
# setPacketLoss 2.5%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=true --concurrent=1 --optional=TenthRoundReliableDC2.5 --protocol=datachannel --repeat=15 --message-size=500

# # size={500} round 5.0
# rebootServer
# startApplication
# setPacketLoss 5.0%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false --concurrent=1 --optional=TenthRoundReliableDC5.0 --protocol=datachannel --repeat=15 --message-size=500

# rebootServer
# startApplication
# setPacketLoss 5.0%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=true --concurrent=1 --optional=TenthRoundReliableDC5.0 --protocol=datachannel --repeat=15 --message-size=500

# # END

# # size={2500} round 0.0
# # rebootServer
# # startApplication

# # node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false --concurrent=1 --optional=NinthRoundReliableDC --protocol=datachannel --repeat=15

# rebootServer
# startApplication

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=true --concurrent=1 --optional=NinthRoundReliableDC --protocol=datachannel --repeat=15 --message-size=2500

# # size={2500} round 2.5
# rebootServer
# startApplication
# setPacketLoss 2.5%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false --concurrent=1 --optional=NinthRoundReliableDC2.5 --protocol=datachannel --repeat=15 --message-size=2500

# rebootServer
# startApplication
# setPacketLoss 2.5%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=true --concurrent=1 --optional=NinthRoundReliableDC2.5 --protocol=datachannel --repeat=15 --message-size=2500

# # size={2500} round 5.0
# rebootServer
# startApplication
# setPacketLoss 5.0%

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false --concurrent=1 --optional=NinthRoundReliableDC5.0 --protocol=datachannel --repeat=15 --message-size=2500

rebootServer
startApplication
setPacketLoss 5.0%

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=true --concurrent=1 --optional=NinthRoundReliableDC5.0 --protocol=datachannel --repeat=15 --message-size=2500

# END

# size={5000} round 0.0
# rebootServer
# startApplication

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false --concurrent=1 --optional=NinthRoundReliableDC --protocol=datachannel --repeat=15

# rebootServer
# startApplication

# node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=true --concurrent=1 --optional=NinthRoundReliableDC --protocol=datachannel --repeat=15 --message-size=2500

# size={5000} round 2.5
rebootServer
startApplication
setPacketLoss 2.5%

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false --concurrent=1 --optional=EighthRoundReliableDC2.5 --protocol=datachannel --repeat=15 --message-size=5000

rebootServer
startApplication
setPacketLoss 2.5%

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=true --concurrent=1 --optional=EighthRoundReliableDC2.5 --protocol=datachannel --repeat=15 --message-size=5000

# size={5000} round 5.0
rebootServer
startApplication
setPacketLoss 5.0%

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=false --concurrent=1 --optional=EighthRoundReliableDC5.0 --protocol=datachannel --repeat=15 --message-size=5000

rebootServer
startApplication
setPacketLoss 5.0%

node index.js -u http://10.133.58.193:9000/empty -w ws://10.133.58.193:9000/websocket --messages=480 --interval=250 --ordered=true --concurrent=1 --optional=EighthRoundReliableDC5.0 --protocol=datachannel --repeat=15 --message-size=5000

# END
