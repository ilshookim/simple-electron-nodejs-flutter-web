'use strict'

const NanoId = require('nanoid');

const logger = require('electron-log');
const router = require('express').Router();
const api = require('./index');

const connections = new Map();

api.localbus.on('serial.*', (key, uid, message) => {
  const path = Buffer.from(key, 'base64').toString('utf8');
  const json = {type: 'serial', path: path, msg: message};
  const payload = JSON.stringify(json);
  const broadcast = true;

  connections.forEach(function (ws, uid2) {
    const send = broadcast;
    if (send) ws.send(JSON.stringify(payload), function(err) {
      if (err) logger.info(`Port ${path} -> Websocket ${uid2} error on send ${err.message}`);
      else logger.info(`Port ${path} -> Websocket ${uid2} to ${payload}`);
    });
  });
});

router.ws('/', function(ws, req) {
  ws.uid = uid();
  connections.set(ws.uid, ws);

  ws.on('message', (message) => {
    const payload = parseJson(message);
    const json = !isString(payload);
    const echo = json && payload.type === 'echo';
    const log = json && payload.type === 'log';

    // {'type': 'echo', 'msg': 'Welcome!'}
    // {'type': 'log', 'level': 'info', 'logger': 'App', 'msg': 'Logging'}
    // {'msg': 'relayed to serial port'}
    // others 'relayed to serial port'
    if (echo) ws.send(payload.msg);
    else if (log) logger.info(`Websocket ${ws.uid} ${payload.msg}`);
    else if (json) api.localbus.emit(`ws.${ws.uid}`, ws.uid, `${payload.msg}`);
    else api.localbus.emit(`ws.${ws.uid}`, ws.uid, `${message}`);
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

function isString(str) {
  return typeof str === 'string' || str instanceof String;
}

function parseJson(payload) {
  let parsed = null;
  try {
    parsed = JSON.parse(payload);
  } catch (e) {
    parsed = payload;
  }
  return parsed;
}

module.exports = router;
