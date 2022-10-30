'use strict'

module.exports = {
  development: {
    client: 'sqlite3',
    connection: {
      filename: `${__dirname.replace('app.asar', '')}/db/data.sqlite3`,
    },
    useNullAsDefault: true,
    migrations: {
      tableName: 'knex_migrations',
      directory: `${__dirname}/db/migrations`,
    },
    seeds: {
      directory: `${__dirname}/db/seeds`,
    }
  }
}
