const puppeteer = require('puppeteer');

async function websocket(configuration) {
    const browser = await puppeteer.launch();

    async function createPage(browser) {
        const page = await browser.newPage();

        await page.exposeFunction('getTime', () => process.hrtime() );
        await page.exposeFunction('getTimeDiff', (start) => process.hrtime(start) );

        return page
    }

    const pages = await Promise.all(Array.from({length: configuration.concurrent_connections}, (x, i) => i).map(() => {
        return createPage(browser)
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

                    const payload = conf.payload;
                    payload.time_send = Date.now();

                    // window.getTime().then((t) => {
                    //     payload.hr_time_send = t;
                    // }).then(() => {
                    co.ws.send(JSON.stringify(payload));
                    // });

                    timerIndex += 1;

                    if (timerIndex === index) {
                        clearTimeout(timer);
                    }

                }, conf.interval);

                co.ws.onerror = (err) => {
                    rej(err);
                };

                co.ws.onmessage = (event) => {

                    const event_data = JSON.parse(event.data);
                    event_data.time_received = Date.now();

                    // window.getTimeDiff(event_data.hr_time_send).then((diff) => {
                    //     event_data.hr_time_diff = diff;
                    // });

                    co.result.push(event_data);
                    received += 1;

                    if (received === conf.messages) {
                        co.ws.close();
                        co.cmd.end_experiment = Date.now();
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
