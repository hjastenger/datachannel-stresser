const puppeteer = require('puppeteer');

async function tryDataChannel(configuration, hookContainer) {
    configuration.protocol = 'datachannel';
    const browser = await puppeteer.launch();
    const page = await browser.newPage();
    await page.goto(configuration.url);

    const stringified = {};

    const result = await websocketSession(configuration, stringified);

    result.map((result) => hookContainer.onResult(result, configuration));

    await browser.close();

    function websocketSession(conf, innerFunctions) {
        return page.evaluate((conf, fn) => {
            function websocket_call() {
                const peerConnection = new RTCPeerConnection();
                const dataChannel = peerConnection.createDataChannel("channel",
                    { ordered:false });

                return new Promise((res, rej) => {
                    const ws = new WebSocket(conf.ws_url);
                    ws.onopen = () => {
                        peerConnection.createOffer()
                            .then(function(desc) {
                                return peerConnection.setLocalDescription(desc);
                            }).catch(
                            function(error) {
                                rej(error);
                            }
                        );
                    };

                    ws.onerror = (err) => {
                        rej(err);
                    };

                    ws.onmessage = function(event) {
                        const data = JSON.parse(event.data);
                        if(data.type === "offer") {
                            const sd = new RTCSessionDescription({type: "answer", sdp: data.answer});
                            peerConnection.setRemoteDescription(sd).then(function (sess) {
                                console.log("Set remote with success ");
                            }).catch(function(e){
                                rej(e);
                            });
                        }
                    };
                    peerConnection.onicecandidate = function(e) {
                        console.log('IceCand: ' + JSON.stringify(e));
                        if (peerConnection.iceGatheringState === 'complete') {
                            console.log("Candidate: " + JSON.stringify(e.candidate));
                            console.log("IceState" + peerConnection.iceGatheringState);
                            const offer = JSON.stringify(
                                peerConnection.localDescription
                            );
                            ws.send(offer);
                        }
                    };

                    dataChannel.onopen = function (e) {
                        ws.close();
                        res(dataChannel);
                    };
                })
                    .then((dc) => {
                        return new Promise((res, rej) => {
                            const index = conf.messages;
                            let received = 0;
                            let result = [];


                            let timerIndex = 0;

                            const timer = setInterval(() => {

                                if(timerIndex === index) {
                                    clearTimeout(timer);
                                } else {
                                    const payload = conf.payload;
                                    payload.time_send = Date.now();
                                    dc.send(JSON.stringify(payload));
                                    timerIndex += 1;
                                }
                            }, conf.interval);

                            dc.onerror = (err) => {
                                rej(err);
                            };

                            dc.onmessage = (event) => {
                                result.push(JSON.parse(event.data));
                                received += 1;

                                if(received === conf.messages) {
                                    dc.close();
                                    res(result);
                                }
                            }
                        });
                    })
            }

            return Promise.all(Array.from({length: conf.concurrent_connections}, (x, i) => i).map(() => {
                return websocket_call()
            }));

        }, configuration, innerFunctions);
    }
}

module.exports = tryDataChannel;
