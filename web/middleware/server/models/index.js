'use strict'

const Fs = require('fs');
const Path = require('path');

const db = require('../../db');

function getModelFiles(dir) {
  return Fs.readdirSync(dir)
    .filter(file => (file.indexOf('.') !== 0) && (file !== 'index.js') && (file !== 'query.js'))
    .map(file => Path.join(dir, file));
}

// Gather up all model files (i.e., any file present in the current directory
// that is not this file) and export them as properties of an object such that
// they may be imported using destructuring like
// `const { MyModel } = require('./models')` where there is a model named
// `MyModel` present in the exported object of gathered models.
const files = getModelFiles(__dirname);

const models = files.reduce(function (models, filename) {
  const initModel = require(filename);
  const model = initModel(db);
  if (model) models[model.name] = model;
  return models;
}, {});

module.exports = models;
