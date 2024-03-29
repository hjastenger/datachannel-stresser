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
const websocketConnection = require('./websocket.js');


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
    .option('-s, --message-size <int>', 'size of the message in kb', parseInt)
    .option('-r, --repeat <int>', 'number of repeats', parseInt)
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
    repeat: 1,
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
    repeat: program.repeat || defaultConfiguration.repeat,
    retransmits: program.retransmitTimes,
    retransmitTimes: program.retransmitTimeout,
    message_size: program.messageSize,
    payload: getPayload(program),
    protocol: program.protocol || defaultConfiguration.protocol,
    optional: program.optional,

};

function getPayload(conf) {
    if(conf.payload && conf.messageSize) {
        logger.error("Conflicting configuration settings, payload and message size can't both be specified");
        process.kill(1);
    } else if(conf.payload) {
        return {data: loadJSON(conf.payload)};
    } else if(conf.messageSize) {
        return {data: Buffer.alloc(conf.messageSize).toString()};
    } else {
        return {data: defaultConfiguration.payload};
    }
}

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

async function executeWarmUp(conf) {
    logger.info("Starting warm up.");
    const warmUpConf = Object.assign({}, conf);
    const msInM = 1000*60;
    warmUpConf.repeat = 1;
    warmUpConf.interval = msInM/conf.messages;
    warmUpConf.optional += "WarmUp";
    let result = [];


    switch (warmUpConf.protocol) {
        case "datachannel":
            result = await executeDataChannel(warmUpConf);
            break;
        case "websocket":
            result = await executeWebsocket(warmUpConf);
            break;
        default:
            logger.error(`protocol ${program.protocol} not recognized!`);
            process.exit(1);
    }

    const tags = createTagList(warmUpConf);
    tags.push("experiment");
    const times = {start: [], end: []};


    // Multiple connections could be started, making it harder to define the starting point. Therefor
    // get all the startings points of the different connections and select the lowest, same for end point.
    // The only difference is that the amount of succeeded connections in an unreliable configuration could
    // vary.
    await Promise.all(result.map((connection) => {
        times.start.push(connection.cmd.start_experiment);
        times.end.push(connection.cmd.end_experiment);

        return onResult(connection, warmUpConf);
    }));

    logger.info("InfluxDB query successfully inserted");
    await postAnnotation(Math.min(...times.start), Math.max(...times.end), tags);
    logger.info("Grafana annotation successfully inserted");

    logger.info("Done warming up.")
}

async function execute(conf) {
    await executeWarmUp(conf);
    for(let x = 1; x <= conf.repeat; x++) {
        conf.connection_nr = x;
        let result = [];
        switch (configuration.protocol) {
            case "datachannel":
                result = await executeDataChannel(conf);
                break;
            case "websocket":
                result = await executeWebsocket(conf);
                break;
            default:
                logger.error(`protocol ${program.protocol} not recognized!`);
                process.exit(1);
        }

        const tags = createTagList(conf);
        tags.push("experiment");
        const times = {start: [], end: []};


        // Multiple connections could be started, making it harder to define the starting point. Therefor
        // get all the startings points of the different connections and select the lowest, same for end point.
        // The only difference is that the amount of succeeded connections in an unreliable configuration could
        // vary.
        await Promise.all(result.map((connection) => {
            times.start.push(connection.cmd.start_experiment);
            times.end.push(connection.cmd.end_experiment);

            return onResult(connection, conf);
        }));

        logger.info("InfluxDB query successfully inserted");
        await postAnnotation(Math.min(...times.start), Math.max(...times.end), tags);
        logger.info("Grafana annotation successfully inserted");

        logger.info(`Successfully finished round ${x} of ${conf.repeat}!`);
    }
}

async function executeDataChannel(conf) {
    return await dataChannelConnection(conf);
}

async function executeWebsocket(conf) {
    try {
        return await websocketConnection(conf);
    } catch(e) {
        console.log("Failing to execute websocket");
        console.log(e);
    }
}

const ts = 1483228800000;

function onResult(i, conf) {
    const tagList = createTagList(conf);
    const NS_PER_SEC = 1e9;

    let qstring = i.result.reduce((acc, cv) => {
        const delta_t = (cv.time_send - i.cmd.start_experiment);

        const timeshifted = ts + delta_t;
        const nanoseconds = cv.hr_time_diff[0] * NS_PER_SEC + cv.hr_time_diff[1];

        acc += `timeshift,${tagList.join(",")} value=${nanoseconds} ${timeshifted}\n`;
        acc += `latency,${tagList.join(",")} value=${nanoseconds} ${cv.time_received}\n`;

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
