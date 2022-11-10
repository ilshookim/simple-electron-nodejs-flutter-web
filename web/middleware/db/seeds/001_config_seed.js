'use strict'

const { Config } = require('../../server/models')

exports.seed = db => db(Config.tableName).del()
  .then(() => [
    {
      key: 'locale',
      value: 'en'
    },
    {
      key: 'demo',
      value: 'true'
    },
    {
      key: 'serialPort',
      value: 'none'
    },
    {
      key: 'baudRate',
      value: '115200'
    }
  ])
  .then(newConfigs => Promise.all(newConfigs.map(config => Config.create(config))))
  .catch(err => console.log('err: ', err))
