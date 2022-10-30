'use strict'

const EventEmitter2 = require('eventemitter2');

const localbus = new EventEmitter2({
  // set this to `true` to use wildcards
  wildcard: true,
  // the delimiter used to segment namespaces
  delimiter: '.', 
  // set this to `true` if you want to emit the newListener event
  newListener: false, 
  // set this to `true` if you want to emit the removeListener event
  removeListener: false, 
  // the maximum amount of listeners that can be assigned to an event
  maxListeners: 10,
  // show event name in memory leak message when more than maximum amount of listeners is assigned
  verboseMemoryLeak: false,
  // disable throwing uncaughtException if an error event is emitted and it has no listeners
  ignoreErrors: false
});

const [BAD_REQUEST, UNAUTHORIZED, FORBIDDEN, CONFLICT, NOT_FOUND, UNPROCESSABLE, GENERIC_ERROR] = [400, 401, 403, 409, 404, 422, 500];

function unauthorized(err, req, res, next) {
  if (err.status !== UNAUTHORIZED) return next(err);

  res.status(UNAUTHORIZED).send({
    ok: false,
    message: err.message || 'Unauthorized',
    errors: [err],
  });
}

function forbidden(err, req, res, next) {
  if (err.status !== FORBIDDEN) return next(err);

  res.status(FORBIDDEN).send({
    ok: false,
    message: err.message || 'Forbidden',
    errors: [err],
  });
}

function conflict(err, req, res, next) {
  if (err.status !== CONFLICT) return next(err);

  res.status(CONFLICT).send({
    ok: false,
    message: err.message || 'Conflict',
    errors: [err],
  });
}

function badRequest(err, req, res, next) {
  if (err.status !== BAD_REQUEST) return next(err);

  res.status(BAD_REQUEST).send({
    ok: false,
    message: err.message || 'Bad Request',
    errors: [err],
  });
}

function unprocessable(err, req, res, next) {
  if (err.status !== UNPROCESSABLE) return next(err);

  res.status(UNPROCESSABLE).send({
    ok: false,
    message: err.message || 'Unprocessable entity',
    errors: [err],
  });
}

// If there's nothing left to do after all this (and there's no error),
// return a 404 error.
function notFound(err, req, res, next) {
  if (err.status !== NOT_FOUND) return next(err);

  res.status(NOT_FOUND).send({
    ok: false,
    message: err.message || 'The requested resource could not be found',
  });
}

// If there's still an error at this point, return a generic 500 error.
function genericError(err, req, res, next) {
  res.status(GENERIC_ERROR).send({
    ok: false,
    message: err.message || 'Internal server error',
    errors: [err],
  });
}

// If there's nothing left to do after all this (and there's no error),
// return a 404 error.
function catchall(req, res, next) {
  res.status(NOT_FOUND).send({
    ok: false,
    message: 'The requested resource could not be found',
  });
}

const exportables = {
  unauthorized,
  forbidden,
  conflict,
  badRequest,
  unprocessable,
  genericError,
  notFound,
  catchall
};

function resError ({ status = 500, message = 'Something went wrong' }) {
  const error = new Error(message);
  error.status = status;
  return error;
};

module.exports = {
  BAD_REQUEST,
  UNAUTHORIZED,
  FORBIDDEN,
  CONFLICT,
  NOT_FOUND,
  UNPROCESSABLE,
  GENERIC_ERROR,
  ...exportables,
  allErrors: Object.keys(exportables).map(key => exportables[key]),
  resError,
  localbus,
};
