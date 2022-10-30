'use strict'

const env = 'development';
const knexfile = require('../knexfile');
const db = require('knex')(knexfile[env]);

module.exports = db;
