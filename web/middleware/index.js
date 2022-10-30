#!/usr/bin/env node

'use strict'

const logger = require('electron-log');
const server = require('./server')
const port = process.env.PORT || 8090;

const app = server.listen(port, () => {
  logger.info(`Server started on port ${ port }`);
});

app.on('error', err => {
  logger.error('ERROR: ', err);
});

process.on( 'SIGINT', () => {
  logger.info( "gracefully shutting down from SIGINT (Crtl-C)" );
  process.exit( )
});

process.on('SIGTERM', () => {
  logger.info('middleware killed - SIGTERM fired');
});

process.on('exit', () => {
  logger.info('middleware exit');
});
