const puppeteer = require('puppeteer');

async function websocket(configuration) {
    const browser = await puppeteer.launch();

    const pages = await Promise.all(Array.from({length: configuration.concurrent_connections}, (x, i) => i).map(() => {
        return browser.newPage()
    }));

    await Promise.all(pages.map((p) => p.goto(configuration.url)));

    function inPage(conf) {
        return new Promise((res, rej) => {
            const cmd = {};

            const ws = new WebSocket(conf.ws_url);
            ws.onopen = () => {
                res({ ws: ws, cmd: cmd });
            };

            ws.onerror = (err) => {
                rej(err);
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
                        co.ws.send(JSON.stringify(payload));
                        timerIndex += 1;
                    }
                }, conf.interval);

                co.ws.onerror = (err) => {
                    rej(err);
                };

                co.ws.onmessage = (event) => {

                    const event_data = JSON.parse(event.data);
                    event_data.time_received = Date.now();
                    co.result.push(event_data);
                    received += 1;

                    if (received === conf.messages) {
                        co.ws.close();
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

module.exports = websocket;
