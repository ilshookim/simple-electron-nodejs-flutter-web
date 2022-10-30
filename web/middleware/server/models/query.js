'use strict'

module.exports = function ({
  db = {}, name = 'name', tableName = 'tablename', selectableProps = [], timeout = 1000,
}) {
  function create(props) {
    delete props.id; // not allowed to set `id`

    return db.insert(props)
      .returning(selectableProps)
      .into(tableName)
      .timeout(timeout);
  }

  function findAll() {
    return db.select(selectableProps)
      .from(tableName)
      .timeout(timeout);
  }

  function find(filters) {
    return db.select(selectableProps)
      .from(tableName)
      .where(filters)
      .timeout(timeout);
  }

  // Same as `find` but only returns the first match if >1 are found.
  function findOne(filters) {
    return find(filters)
      .then(results => {
        if (!Array.isArray(results))
          return results;

        return results[0];
      });
  }

  function findById(id) {
    return db.select(selectableProps)
      .from(tableName)
      .where({ id })
      .timeout(timeout);
  }

  function update(id, props) {
    delete props.id; // not allowed to set `id`

    return db.update(props)
      .from(tableName)
      .where({ id })
      .returning(selectableProps)
      .timeout(timeout);
  }

  function destroy(id) {
    return db.del()
      .from(tableName)
      .where({ id })
      .timeout(timeout);
  }

  return {
    name,
    tableName,
    selectableProps,
    timeout,
    create,
    findAll,
    find,
    findOne,
    findById,
    update,
    destroy
  };
}
