const puppeteer = require('puppeteer');

async function datachannel(configuration) {
    const browser = await puppeteer.launch();

    const pages = await Promise.all(Array.from({length: configuration.concurrent_connections}, (x, i) => i).map(() => {
        return browser.newPage()
    }));

    await Promise.all(pages.map((p) => p.goto(configuration.url)));

    function inPage(conf) {
        return new Promise((res, rej) => {
            const peerConnection = new RTCPeerConnection();
            const dataChannel = peerConnection.createDataChannel("channel",
                { ordered: conf.ordered });

            const ws = new WebSocket(conf.ws_url);
            ws.onopen = () => {
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
                    const sd = new RTCSessionDescription({type: "answer", sdp: data.answer});
                    peerConnection.setRemoteDescription(sd).then(function (sess) {
                        console.log("Set remote with success ");
                    }).catch(function (e) {
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
                ws.close();
                res(dataChannel);
            };
        }).then((dc) => {
            return new Promise((res, rej) => {

                const index = conf.messages;
                let received = 0;
                let result = [];


                let timerIndex = 0;

                const timer = setInterval(() => {

                    if (timerIndex === index) {
                        clearTimeout(timer);
                    } else {
                        const payload = conf.payload;
                        payload._metadata = {};
                        payload.time_send = Date.now();
                        payload._metadata.time_send = Date.now();
                        dc.send(JSON.stringify(payload));
                        timerIndex += 1;
                    }
                }, conf.interval);

                dc.onerror = (err) => {
                    rej(err);
                };

                dc.onmessage = (event) => {
                    const event_data = JSON.parse(event.data);
                    event_data.time_received = Date.now();
                    result.push(event_data);
                    received += 1;

                    if (received === conf.messages) {
                        dc.close();
                        res(result);
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
