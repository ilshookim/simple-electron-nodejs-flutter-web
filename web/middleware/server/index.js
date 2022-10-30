'use strict'

const Path = require('path');
const Cors = require('cors');
const Morgan = require('morgan');
const Express = require('express');
const ExpressWS = require('express-ws')(Express());
const BodyParser = require('body-parser');

const logger = require('electron-log');
const app = ExpressWS.app;

app.use(Morgan('short', {
  stream: {
    write: function onWriteStream(message) {
      const messageWithoutNewline = message.substring(0, message.lastIndexOf(`\n`));
      logger.info(` ${messageWithoutNewline}`);
    },
  },
}));

app.use(Cors());
app.use(Express.json());
app.use(BodyParser.json());
app.use(Express.static(Path.resolve(__dirname, '../..')));
app.disable('x-powered-by');

app.use('/', [
  require('./api/config'),
  require('./api/serial'),
  require('./api/ws'),
]);

app.get('/hello', function (req, res) {
  res.send('Welcome!');
});

app.use(require('./api').allErrors);

module.exports = app;
