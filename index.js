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

// Please don't re-use this.
function parseBoolean(value) {
    return value === 'true';
}

program
    .version('0.1.0')
    .option('-u, --url <url>', 'Website URL')
    .option('-w, --wsUrl <url>', 'websocket url used for signalling')
    .option('-m, --messages <int>', 'number of messages to be send', parseInt)
    .option('-i, --interval <int>', 'interval in which the messages are send', parseInt)
    .option('-d, --payload <file>', 'location of json blob to be used for communicating')
    .option('-o, --ordered <boolean>', 'whether to send the messages in an ordered fashion', parseBoolean)
    .option('-p, --protocol <datachannel | websocket | post]>', 'specify the DataChannel to be ordered or not')
    .option('-c, --concurrent <int>', 'specify the amount of concurrent connections per process', parseInt)
    .option('-x, --retransmit-times <int>', 'specify number of retransmission times on each message', parseInt)
    .option('-y, --retransmit-timeout <int>', 'specify miliseconds before dropping a message', parseInt)
    .option('-z, --optional <string>', 'specify number of retransmission times on each message')

;

program.parse(process.argv);

const defaultConfiguration = {
    url: "http://localhost:9000",
    ws_url: "ws://localhost:9000/websocket",
    protocol: "datachannel",
    concurrent_connections: 1,
    messages: 10,
    interval: 300,
    ordered: true,
    payload: {}
};

if(program.retransmitTimes && program.retransmitTimeout) {
    logger.error("--retransmit-times && retransmit-timeout can't both be active at the same time.");
    process.kill(1);
}

const configuration = {
    url: program.url || defaultConfiguration.url,
    ws_url: program.wsUrl || defaultConfiguration.ws_url,
    concurrent_connections: program.concurrent || defaultConfiguration.concurrent_connections,
    messages: program.messages || defaultConfiguration.messages,
    interval: program.interval || defaultConfiguration.interval,
    ordered: program.ordered && defaultConfiguration.ordered,
    retransmits: program.retransmitTimes,
    retransmitTimes: program.retransmitTimeout,
    payload: (program.payload && loadJSON(program.payload)) || defaultConfiguration.payload,
    protocol: program.protocol || defaultConfiguration.protocol,
    optional: program.optional,
};

function createTagList(conf) {
    const blacklist = ["url", "ws_url", "payload"];
    const tags = [];

    for(const attr in conf) {
        if(conf.hasOwnProperty(attr) && !blacklist.includes(attr) && conf[attr] !== undefined) {
            tags.push(`${attr}=${conf[attr]}`)
        }
    }
    return tags;
}

async function execute(conf) {
    let result = [];
    switch(configuration.protocol) {
        case "datachannel":
            result = await executeDataChannel(conf);
            break;
        default:
            logger.error(`protocol ${program.protocol} not recognized!`);
            process.exit(1);
    }

    const tags = createTagList(conf);
    tags.push("experiment");
    const times = { start: [], end:[] };


    // Multiple connections could be started, making it harder to define the starting point. Therefor
    // get all the startings points of the different connections and select the lowest, same for end point.
    // The only difference is that the amount of succeeded connections in an unreliable configuration could
    // vary. 
    await Promise.all(result.map((connection) => {
        times.start.push(connection.result[0].time_received);
        times.end.push(connection.result[(connection.cmd.receivedMessages||conf.messages)-1].time_received);

        return onResult(connection, conf);
    }));

    logger.info("InfluxDB query successfully inserted");
    await postAnnotation(Math.min(...times.start), Math.max(...times.end), tags);
    logger.info("Grafana annotation successfully inserted");
}

async function executeDataChannel(conf) {
    return await dataChannelConnection(conf);
}

const ts = 1483228800000;

function onResult(i, conf) {
    const tagList = createTagList(conf);

    let qstring = i.result.reduce((acc, cv) => {
        const diff = cv.time_received - cv.time_send;
        acc += `test_latency,${tagList.join(",")} value=${diff} ${cv.time_received}\n`;

        const delta_t = (cv.time_send - i.cmd.start_experiment);
        const timeshifted = ts + delta_t;
        acc += `random,${tagList.join(",")} value=${diff} ${timeshifted}\n`;
        return acc;
    }, "");

    if(conf.protocol === "datachannel") {
        qstring += `dropped_messages,${tagList.join(",")} value=${i.cmd.droppedMessages || 0}\n`;
    }

    return postData(qstring);
}

function postAnnotation(start, end, tags) {
    return fetch("http://159.65.204.118:3000/api/annotations", {
        body: JSON.stringify({
            "time": start,
            "timeEnd": end,
            "isRegion": true,
            "tags": tags,
            "panelId": 2,
            "text": "Annotation Description"
        }),
        headers: {
            'Authorization': 'Bearer eyJrIjoicjFaZ0Rub0w3YTJTUlNmb25FVE9uY2kyc0xvOG9OMFciLCJuIjoic29tZXRoaW5nIiwiaWQiOjF9',
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        },
        method: 'POST',
    });
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

execute(configuration);
