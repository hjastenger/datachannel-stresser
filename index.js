const fetch = require('node-fetch');
const program = require('commander');
const winston = require('winston');

const {
    createLogger,
    format,
    transports
} = winston;

const {
    printf,
    combine,
    timestamp
} = format;

const fs = require('fs');

const dataChannelConnection = require('./datachannel.js');

const myFormat = printf(info => {
    return `${info.timestamp} ${info.level}: ${info.message}`;
});

const logger = createLogger({
    format: combine(
        timestamp(),
        myFormat
    ),
    transports: [
        new transports.File({ filename: 'error.log', level: 'error' }),
        new transports.File({ filename: 'combined.log' }),
        new transports.Console()
    ]
});

program
    .version('0.1.0')
    .option('-u, --url <url>', 'Website URL')
    .option('-ws, --wsUrl <url>', 'websocket url used for signalling')
    .option('-m, --messages <n>', 'number of messages to be send')
    .option('-i, --interval <n>', 'interval in which the messages are send')
    .option('-p, --payload <json>', 'location of json blob to be used for communicating')
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
    interval: 350,
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
    payload: (program.payload && loadJSON(program.payload)) || defaultConfiguration.payload
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

function loadJSON(location) {
    try {
        const filepath = `${__dirname}/${location}`;
        const data = fs.readFileSync(filepath);
        logger.info(`Loaded and parsed payload file: '${filepath}'`);
        return JSON.parse(data.toString());
    }
    catch (e) {
        logger.error("loadJSON error: " + e.toString());
        process.exit(1)
    }
}
