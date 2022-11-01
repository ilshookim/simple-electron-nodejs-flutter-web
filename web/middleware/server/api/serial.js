'use strict'

const { SerialPort } = require('serialport');

const logger = require('electron-log');
const router = require('express').Router();
const api = require('./index');

function list(req, res, next) {
  SerialPort.list().then((ports, err) => {
    if (err) {
      next(api.resError({
        status: api.GENERIC_ERROR,
        message: err
      }));
    } else if (ports.size === 0) {
      next(api.resError({
        status: api.NOT_FOUND,
        message: 'Serial port not found',
      }));
    } else {
      const portList = [];
      for (const port of ports) portList.push(port.path);
      res.json({
        ok: true,
        message: 'Serial port list',
        portList
      });
    }
  });
}

const serials = new Map();

api.localbus.on('ws.*', (uid, data) => {
  serials.forEach(function (port, key) {
    const path = Buffer.from(key, 'base64').toString('utf8');
    port.write(`${data}`, function(err) {
      if (err) logger.info(`Websocket ${uid} -> Port ${path} error on write ${err.message}`);
      else logger.info(`Websocket ${uid} -> Port ${path} to ${data}`);
    });
  });
});

function open(req, res, next) {
  const path = req.body.path;
  const uid = req.body.websocket;
  const key = Buffer.from(path).toString('base64');
  if (serials.has(key)) {
    return res.json({
      ok: true,
      message: 'Serial port already open',
      serial: {
        port: req.body,
        state: 'already open',
      },
    });
  }

  const port = new SerialPort(req.body);

  port.on('open', () => {
    logger.info(`Serial ${path} open`);
    serials.set(key, port);

    res.json({
      ok: true,
      message: 'Serial port open',
      serial: {
        port: req.body,
        state: 'open',
      },
    });
  })

  port.on('data', (data) => {
    logger.info(`Serial ${path}: ${data}`);
    api.localbus.emit(`serial.${key}`, key, uid, data);
  })

  port.on('disconnect', () => {
    logger.info(`Serial ${path} disconnected`);
    serials.delete(key);
  });

  port.on('close', () => {
    logger.info(`Serial ${path} closed`);
    serials.delete(key);
  });

  port.on('error', (err) => {
    logger.info(`Serial ${path} error: ${err.message}`);
    serials.delete(key);
    next(api.resError({
      status: api.UNPROCESSABLE,
      message: `Serial port unprocessable: ${err.message}`,
    }));
  })
}

function close(req, res, next) {
  const path = req.body.path;
  const key = Buffer.from(path).toString('base64');

  if (serials.has(key)) {
    const port = serials.get(key);
    port.close(); // path will be delete on close callback

    res.json({
      ok: true,
      message: 'Serial port close',
      serial: {
        port: req.body,
        state: 'close',
      },
    });
  } else {
    SerialPort.list().then((ports, err) => {
      if (err) {
        next(api.resError({
          status: api.GENERIC_ERROR,
          message: err
        }));
      } else if (ports.filter(port => port.path === path).length > 0) {
        const portList = [];
        for (const port of ports) portList.push(port.path);
        res.json({
          ok: true,
          message: 'Serial port already close',
          portList
        });
      } else {
        next(api.resError({
          status: api.NOT_FOUND,
          message: 'Serial port not found',
        }));
      }
    });
  }
}

function send(req, res, next) {
  const path = req.body.path;
  const data = req.body.data;
  const key = Buffer.from(path).toString('base64');
  const broadcast = true;

  logger.info(`-> Port ${path} to ${data} until ${serials.size}`);
  serials.forEach(function (port, key2) {
    const path2 = Buffer.from(key2, 'base64').toString('utf8');
    const write = broadcast;
    if (write) port.write(`${data}`, function(err) {
      if (err) logger.info(`-> Port ${path2} error on write ${err.message}`);
      else logger.info(`-> Port ${path2} to ${data}`);
    });
  });

  res.json({
    ok: true,
    message: 'Serial port send',
    serial: {
      port: req.body,
      state: serials.has(key) ? 'open' : 'close',
    },
  });
}

function recv(req, res, next) {
  const path = req.body.path;
  const data = req.body.data;
  const uid = req.body.websocket;
  const key = Buffer.from(path).toString('base64');

  api.localbus.emit(`serial.${key}`, key, uid, data);

  res.json({
    ok: true,
    message: 'Serial port recv',
    serial: {
      port: req.body,
      state: serials.has(key) ? 'open' : 'close',
    },
  });
}

router.route('/serial')
  .get(list);

router.route('/serial/open')
  .post(open);

router.route('/serial/close')
  .post(close);

router.route('/serial/send')
  .post(send);

router.route('/serial/recv')
  .post(recv);

module.exports = router;
