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

function open(req, res, next) {
  const path = req.body.path;
  if (serials.has(path)) {
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
    serials.set(path, port);

    api.localbus.on('ws.*', (message) => {
      port.write(`${message}`, function(err) {
        if (err) logger.info(`Serial ${path} error on write ${err.message}`);
        else logger.info(`Serial ${path} to ${message}`);
      });
    });

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
    api.localbus.emit(`serial.${path}`, data);
  })

  port.on('disconnect', () => {
    logger.info(`Serial ${path} disconnected`);
    serials.delete(path);
  });

  port.on('close', () => {
    logger.info(`Serial ${path} closed`);
    serials.delete(path);
  });

  port.on('error', (err) => {
    logger.info(`Serial ${path} error: ${err.message}`);
    serials.delete(path);
    next(api.resError({
      status: api.UNPROCESSABLE,
      message: `Serial port unprocessable: ${err.message}`,
    }));
  })
}

function close(req, res, next) {
  const path = req.body.path;

  if (serials.has(path)) {
    const port = serials.get(path);
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

router.route('/serial')
  .get(list);

router.route('/serial/open')
  .post(open);

router.route('/serial/close')
  .post(close);

module.exports = router;
