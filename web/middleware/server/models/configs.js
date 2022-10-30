'use strict'

const query = require('./query');

const name = 'Config';
const tableName = 'configs';

const selectableProps = [
  'id',
  'key',
  'value',
];

module.exports = db => {
  return {
    ...query({
      db,
      name,
      tableName,
      selectableProps
    })
  };
};
