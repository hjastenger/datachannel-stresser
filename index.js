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
    .option('-w, --wsUrl <url>', 'websocket url used for signalling')
    .option('-m, --messages <n>', 'number of messages to be send')
    .option('-i, --interval <n>', 'interval in which the messages are send')
    .option('-d, --payload <json>', 'location of json blob to be used for communicating')
    .option('-d, --payload <json>', 'location of json blob to be used for communicating')
    .option('-p, --protocol <[datachannel | websocket | post]>', 'specify the DataChannel to be ordered or not')
    .option('-cc, --concurrent <b>', 'specify the amount of concurrent connections per process')
    .option('-rtx, --retransmit-times <n>', 'specify number of retransmission times on each message')
    .option('-rto, --retransmit-timeout <n>', 'specify miliseconds before dropping a message')
;

program.parse(process.argv);

const defaultConfiguration = {
    url: "http://localhost:9000",
    ws_url: "ws://localhost:9000/websocket",
    concurrent_connections: 5,
    messages: 100,
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
    payload: (program.payload && loadJSON(program.payload)) || defaultConfiguration.payload
};

const hooks = {
    onResult: onResult
};

dataChannelConnection(configuration, hooks)
    .then((data) => {
        return Promise.all(data.map((connection) => {
            return onResult(connection, configuration);
        }));
    }).then(() => {
        logger.info("InfluxDB query successfully inserted");
    }).then(() => {
        const tags = ["experiment"];
        for(const attr in configuration) {
            const blacklist = ["url", "ws_url", "payload"];
            if(configuration.hasOwnProperty(attr) && !blacklist.includes(attr)) {
                tags.push(`${attr}=${configuration[attr]}`)
            }
        }

        return fetch("http://159.65.204.118:3000/api/annotations", {
            body: JSON.stringify({
                "time": insertion,
                "timeEnd": last_insertion,
                "isRegion":true,
                "tags":tags,
                "panelId":2,
                "text":"Annotation Description"
            }),
            headers: {
                'Authorization': 'Bearer eyJrIjoicjFaZ0Rub0w3YTJTUlNmb25FVE9uY2kyc0xvOG9OMFciLCJuIjoic29tZXRoaW5nIiwiaWQiOjF9',
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            method: 'POST',
        }).then(() => {
            logger.info("Grafana annotation successfully inserted");
        })
    }).catch((e) => {
        console.log("caught error");
        logger.error(e.message);
    });

let insertion;
let last_insertion;

async function onResult(i, conf) {
    const qstring = i.reduce((acc, cv) => {
        const diff = cv.time_received - cv.time_send;
        // acc += `test_latency,ticket=${ticker},protocol=${conf.protocol},concurrency=${conf.concurrent_connections},messages=${conf.messages},interval=${conf.interval} value=${diff} ${(cv.time_received*1e6) }\n`;
        acc += `test_latency,protocol=${conf.protocol},concurrency=${conf.concurrent_connections},messages=${conf.messages},interval=${conf.interval} value=${diff} ${(cv.time_received) }\n`;
        if(!insertion) {
            insertion = cv.time_received;
        }
        last_insertion = cv.time_received;
        return acc;
    }, "");


    return postData(qstring);
}

function postData(payload) {
    const binary = Buffer.from(payload);
    const url = "http://159.65.204.118:8086/write?db=testdb&precision=ms";
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
