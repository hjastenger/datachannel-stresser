const fetch = require('node-fetch');
const program = require('commander');
const logger = require('winston');

const dataChannelConnection = require('./datachannel.js');

program
    .version('0.1.0')
    .option('-u, --url <url>', 'Website URL')
    .option('-uw, --wsUrl <url>', 'websocket url used for signalling')
    .option('-m, --messages <n>', 'number of messages to be send')
    .option('-i, --interval <n>', 'interval in which the messages are send')
    .option('-o, --ordered <b>', 'specify the DataChannel to be ordered or not')
    .option('-cc, --concurrent <b>', 'specify the amount of concurrent connections per process')
    .option('-rtx, --retransmit-times <n>', 'specify number of retransmission times on each message')
    .option('-rto, --retransmit-timeout <n>', 'specify miliseconds before dropping a message')
;

program.parse(process.argv);

const defaultConfiguration = {
    url: "http://localhost:9000",
    ws_url: "ws://localhost:9000/websocket",
    concurrent_connections: 1,
    messages: 1,
    interval: 300,
    ordered: true,
    maxRetransmit: 0,
    payload: {}
};



const configuration = {
    url: program.url || defaultConfiguration.url,
    ws_url: program.wsUrl || defaultConfiguration.ws_url,
    concurrent_connections: program.concurrent || defaultConfiguration.concurrent_connections,
    messages: program.messages || defaultConfiguration.messages,
    interval: program.interval || defaultConfiguration.interval,
    ordered: program.ordered || defaultConfiguration.ordered,
    maxRetransmit: program.retransmitTimes || defaultConfiguration.maxRetransmit,
    payload: defaultConfiguration.payload
};

const hooks = {
    onResult: onResult
};

dataChannelConnection(configuration, hooks);

function onResult(i, conf) {
    const responseTimes = i.map((_) => (_.time_acquired - _.time_send));
    return Promise.all(responseTimes.map((res) => {
        return postData(`response_time,protocol=${conf.protocol},concurrency=${conf.concurrent_connections},messages=${conf.messages},interval=${conf.interval} value=${res}`)
    }));
}

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
