const puppeteer = require('puppeteer');

async function datachannel(configuration) {
    const browser = await puppeteer.launch();

    const pages = await Promise.all(Array.from({length: configuration.concurrent_connections}, (x, i) => i).map(() => {
        return browser.newPage()
    }));

    await Promise.all(pages.map((p) => p.goto(configuration.url)));

    function inPage(conf) {
        function getReliabilityConfiguration() {
            const relConf = { ordered: conf.ordered };
            if(conf.retransmits !== undefined) {
                relConf.maxRetransmits = conf.retransmits;
            } else if(conf.retransmitTimes !== undefined) {
                relConf.maxRetransmitTime = conf.retransmitTimes;
            }
            return relConf;
        }

        return new Promise((res, rej) => {
            const cmd = {};
            const peerConnection = new RTCPeerConnection();

            const reliability = getReliabilityConfiguration();

            const dataChannel = peerConnection.createDataChannel("channel", reliability);

            const ws = new WebSocket(conf.ws_url);
            ws.onopen = () => {
                cmd.start_signalling = Date.now();
                peerConnection.createOffer()
                    .then(function (desc) {
                        return peerConnection.setLocalDescription(desc);
                    }).catch(
                    function (error) {
                        rej(error);
                    }
                );
            };

            ws.onerror = (err) => {
                rej(err);
            };

            ws.onmessage = function (event) {
                const data = JSON.parse(event.data);
                if (data.type === "offer") {
                    cmd.received_offer = Date.now();
                    const sd = new RTCSessionDescription({type: "answer", sdp: data.answer});
                    peerConnection.setRemoteDescription(sd)
                        .catch(function (e) {
                            rej(e);
                        });
                }
            };

            peerConnection.onicecandidate = function (e) {
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
                cmd.datachannel_opened = Date.now();
                ws.close();
                res({ dc: dataChannel, cmd: cmd });
            };
        }).then((co) => {
            return new Promise((res, rej) => {

                const index = conf.messages;
                let received = 0;
                co.result = [];


                let timerIndex = 0;

                const timer = setInterval(() => {
                    if(!co.cmd.start_experiment) {
                        co.cmd.start_experiment = Date.now();
                    }

                    if (timerIndex === index) {
                        co.cmd.end_experiment = Date.now();
                        clearTimeout(timer);
                    } else {
                        const payload = conf.payload;
                        // payload._metadata = {};
                        payload.time_send = Date.now();
                        // payload._metadata.time_send = Date.now();
                        co.dc.send(JSON.stringify(payload));
                        timerIndex += 1;
                    }
                }, conf.interval);

                co.dc.onerror = (err) => {
                    rej(err);
                };

                co.dc.onmessage = (event) => {
                    // Should be able to resolve after messages are dropped. Threshold shouldn't only be the amount of
                    // messages that are send. This way an unreliable datachannel will never resolve because it keeps
                    // waiting for the dropped message. Adding a hard timeout is the only solution.
                    let timeoutResolver;
                    if(conf.retransmits !== undefined || conf.retransmitTimes !== undefined) {
                        if(timeoutResolver) {
                            clearTimeout(timeoutResolver);
                        }
                        timeoutResolver = setTimeout(() => {
                            co.cmd.droppedMessages = conf.messages - received;
                            co.cmd.receivedMessages = received;
                            co.dc.close();
                            res(co);
                        }, 15000);
                    }

                    const event_data = JSON.parse(event.data);
                    event_data.time_received = Date.now();
                    co.result.push(event_data);
                    received += 1;

                    if (received === conf.messages) {
                        co.dc.close();
                        res(co);
                    }
                };
            });
        });
    }

    const result = await Promise.all(pages.map((page) => {
        return page.evaluate(inPage, configuration)
    }));

    await Promise.all(pages.map((p) => p.close()));
    await browser.close();

    return result;
}

module.exports = datachannel;
