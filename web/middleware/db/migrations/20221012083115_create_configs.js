exports.up = db => {
  return db.schema.createTable('configs', t => {
    t.increments('id').primary().unsigned();
    t.string('key');
    t.string('value');
  })
}

exports.down = db => {
  return db.schema.dropTable('configs');
}
