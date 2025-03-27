const express = require('express');
const cluster = require('cluster');
const os = require('os');

const numCPUs = os.cpus().length;

if (cluster.isMaster) {
    console.log(`Master process ${process.pid} is running`);

    // Fork workers
    for (let i = 0; i < numCPUs; i++) {
        cluster.fork();
    }

    cluster.on('exit', (worker, code, signal) => {
        console.log(`Worker ${worker.process.pid} died`);
    });
} else {
    const app = express();
    const port = 3000;

    app.get('/', (req, res) => {
        res.send(`Hello from worker ${process.pid}`);
    });

    app.listen(port, () => {
        console.log(`Worker ${process.pid} listening at http://localhost:${port}`);
    });
}
