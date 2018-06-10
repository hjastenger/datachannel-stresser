const puppeteer = require('puppeteer');
const fetch = require('node-fetch');
const program = require('commander');
const dataChannelConnection = require('./datachannel.js');

program
    .version('0.1.0')
    .option('-u, --url <url>', 'Website URL')
    .option('-uw, --wsUrl <url>', 'websocket url used for signalling')
    .option('-m, --messages <n>', 'number of messages to be send')
    .option('-i, --interval <n>', 'interval in which the messages are send')
    .option('-o, --ordered <b>', 'specify the DataChannel to be ordered or not')
    .option('-rtx, --retransmit-times <n>', 'specify number of retransmission times on each message')
    .option('-rto, --retransmit-timeout <n>', 'specify miliseconds before dropping a message')
;

program.parse(process.argv);

function onResult(i, conf) {
    const responseTimes = i.map((_) => (_.time_acquired - _.time_send));
    return Promise.all(responseTimes.map((res) => {
        return postData(`response_time,protocol=${conf.protocol},concurrency=${conf.concurrent_connections},messages=${conf.messages},interval=${conf.interval} value=${res}`)
    }));
}

const configuration = {
    url: "http://localhost:9000/empty",
    ws_url: "ws://localhost:9000/websocket",
    concurrent_connections: 1,
    messages: 1,
    interval: 300,
    ordered: false,
    maxRetransmit: 0
};

const hooks = {
    onSend: send,
    onResult: onResult
};

dataChannelConnection(configuration, hooks);

// const data = "cpu,host=serverC,region=us_west value=0.95";

function postData(payload) {
    const binary = Buffer.from(payload);
    const url = "http://159.65.204.118:8086/write?db=testdb";
    return fetch(url, {
        body: binary,
        headers: {
            'content-type': 'application/x-binary'
        },
        method: 'POST',
    })
}

async function tryWebSocket() {
    const browser = await puppeteer.launch();
    const page = await browser.newPage();
    await page.goto('http://localhost:9000/empty');

    await page.exposeFunction("doSomething", () => {
        console.log("just do it")
    });
    const websocket_url = "ws://localhost:9000/websocket_ping";
    const result = await websocketSession(websocket_url, 10);

    result.map((i) => {
        console.log(i.time_received - i.time_send)
    });

    await browser.close();

    function websocketSession(websocket_url, connections) {
        return page.evaluate((location, connects) => {
            function websocket_call() {
                return new Promise((res, rej) => {
                    const ws = new WebSocket(location);
                    ws.onopen = () => {
                        const data = {
                            data: "message",
                            time_send: Date.now()
                        };
                        ws.send(JSON.stringify(data));
                        res(ws);
                    };
                    ws.onerror = (err) => {
                        rej(err);
                    }
                }).then((ws) => {
                    return new Promise((res) => {
                        ws.onmessage = (event) => {
                            res(JSON.parse(event.data));
                            ws.close();
                        };
                    });
                })
            }

            return Promise.all(Array.from({length: connects}, (x, i) => i).map(() => {
                return websocket_call()
            }));

        }, websocket_url, connections);
    }
}

// async function tryDataChannel(configuration, hookContainer) {
//     configuration.protocol = 'datachannel';
//     const browser = await puppeteer.launch();
//     const page = await browser.newPage();
//     await page.goto(configuration.url);
//
//     const stringified = {
//         onSend: hookContainer.onSend.toString()
//     };
//
//     const result = await websocketSession(configuration, stringified);
//
//     result.map((result) => hookContainer.onResult(result, configuration));
//
//     await browser.close();
//
//     function websocketSession(conf, innerFunctions) {
//         return page.evaluate((conf, fn) => {
//             const onSend = new Function(' return (' + fn.onSend + ').apply(null, arguments)');
//             function websocket_call() {
//                 const peerConnection = new RTCPeerConnection();
//                 const dataChannel = peerConnection.createDataChannel("channel",
//                     { ordered:false });
//
//                 return new Promise((res, rej) => {
//                     const ws = new WebSocket(conf.ws_url);
//                     ws.onopen = () => {
//                         peerConnection.createOffer()
//                             .then(function(desc) {
//                                 return peerConnection.setLocalDescription(desc);
//                             }).catch(
//                             function(error) {
//                                 rej(error);
//                             }
//                         );
//                     };
//
//                     ws.onerror = (err) => {
//                         rej(err);
//                     };
//
//                     ws.onmessage = function(event) {
//                         const data = JSON.parse(event.data);
//                         if(data.type === "offer") {
//                             const sd = new RTCSessionDescription({type: "answer", sdp: data.answer});
//                             peerConnection.setRemoteDescription(sd).then(function (sess) {
//                                 console.log("Set remote with success ");
//                             }).catch(function(e){
//                                 rej(e);
//                             });
//                         }
//                     };
//                     peerConnection.onicecandidate = function(e) {
//                         console.log('IceCand: ' + JSON.stringify(e));
//                         if (peerConnection.iceGatheringState === 'complete') {
//                             console.log("Candidate: " + JSON.stringify(e.candidate));
//                             console.log("IceState" + peerConnection.iceGatheringState);
//                             const offer = JSON.stringify(
//                                 peerConnection.localDescription
//                             );
//                             ws.send(offer);
//                         }
//                     };
//
//                     dataChannel.onopen = function (e) {
//                         ws.close();
//                         res(dataChannel);
//                     };
//                 })
//                 .then((dc) => {
//                     return new Promise((res, rej) => {
//                         onSend.call(null, res, rej, dc, conf)
//                     });
//                 })
//             }
//
//             return Promise.all(Array.from({length: conf.concurrent_connections}, (x, i) => i).map(() => {
//                 return websocket_call()
//             }));
//
//         }, configuration, innerFunctions);
//     }
// }

function send(res, rej, dc, conf) {
    const index = conf.messages;
    let received = 0;
    let result = [];


    let timerIndex = 0;

    const timer = setInterval(() => {

        if(timerIndex === index) {
            clearTimeout(timer);
        } else {
            const payload = {
                data: "working",
                time_send: Date.now()
            };
            dc.send(JSON.stringify(payload));
            timerIndex += 1;
        }
    }, conf.interval);

    dc.onmessage = (event) => {
        result.push(JSON.parse(event.data));
        received += 1;

        if(received === conf.messages) {
            dc.close();
            res(result);
        }
    }
}
