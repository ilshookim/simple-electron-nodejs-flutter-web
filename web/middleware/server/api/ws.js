'use strict'

const NanoId = require('nanoid');

const logger = require('electron-log');
const router = require('express').Router();
const api = require('./index');

const connections = new Map();

router.ws('/', function(ws, req) {
  ws.uid = uid();
  connections.set(ws.uid, ws);

  api.localbus.on('serial.*', (message) => {
    ws.send(message, function(err) {
      if (err) logger.info(`Websocket ${ws.uid} error on send ${err.message}`);
      else logger.info(`Websocket ${ws.uid} to ${message}`);
    });
  });
  
  const echo = true;
  ws.on('message', (message) => {
    logger.info(`Websocket ${ws.uid}: ${message}`);
    if (echo) ws.send(`${message}`);
    api.localbus.emit(`ws.${ws.uid}`, `${message}`);
  });

  ws.on('close', () => {
    logger.info(`Websocket ${ws.uid} disconnected!`);
    connections.delete(ws.uid);
  });

  ws.on('error', (err) => {
    logger.info(`Websocket ${ws.uid} error: ${err.stack}`);
    connections.delete(ws.uid);
  });

  logger.info(`Websocket ${ws.uid} connected`);
  ws.send(`${ws.uid}`);
});

function uid(length = 10, alphabet = NanoId.urlAlphabet) {
  const nanoid = NanoId.customAlphabet(alphabet, length);
  return nanoid();
}

module.exports = router;
