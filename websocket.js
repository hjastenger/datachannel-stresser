const puppeteer = require('puppeteer');

 async function webSocketConnection() {
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

module.exports = webSocketConnection;
