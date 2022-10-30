'use strict'

const OS = require('os');
const FS = require('fs');
const YAML = require('yaml');

const logger = require('electron-log');
const router = require('express').Router();
const { Config } = require('../models');

function list(req, res, next) {
  Config.findAll()
    .then(function (configs) {
      configs.push({id: -1, key: 'platform', value: OS.platform()});
      configs.push({id: -1, key: 'platformVersion', value: OS.release()});
      try {
        const data = FS.readFileSync(__dirname + '/../../../pubspec.yaml', 'utf8');
        const yaml = YAML.parse(data);
        configs.push({id: -1, key: 'projectVersion', value: `${OS.platform()} ${OS.release()} (${yaml['name']} ${yaml['version']})`});
      }
      catch (exc) {
        configs.push({id: -1, key: 'projectVersion', value: `${OS.platform()} ${OS.release()}`});
      }
      try {
        const data = FS.readFileSync(__dirname + '/../../../package.json', 'utf8');
        const json = JSON.parse(data);
        configs.push({id: -1, key: 'middlewareVersion', value: `node ${process.versions['node']} (${json['productName']} ${json['version']})`});
      }
      catch (exc) {
        configs.push({id: -1, key: 'middlewareVersion', value: `node ${process.versions['node']}`});
      }
      switch (OS.platform()) {
        case 'darwin': configs.push({id: -1, key: 'loggingPath', value: '~/Library/Logs/wapui/main.log'}); break;
        case 'linux': configs.push({id: -1, key: 'loggingPath', value: '~/.config/wapui/logs/main.log'}); break;
        case 'win32': configs.push({id: -1, key: 'loggingPath', value: '%USERPROFILE%\\AppData\\Roaming\\wapui\\logs\\main.log'}); break;
      }
      return configs;
    })
    .then(function (configs) {
      for (const config of configs) {
        if (config.key === 'projectVersion') logger.info(`${config.key}: ${config.value}`);
        if (config.key === 'middlewareVersion') logger.info(`${config.key}: ${config.value}`);
        if (config.key === 'loggingPath') logger.info(`${config.key}: ${config.value}`);
      }
      return configs;
    })
    .then(function (configs) {
      return res.json({
        ok: true,
        message: 'Configs list',
        configs
      });
    })
    .catch(next);
}

function post(req, res, next) {
  const props = req.body;
  let configId;

  Config.create({ ...props })
    .then(config => {
      configId = config.id;
      return config;
    })
    .then(config => res.json({
      ok: true,
      message: `Config created`,
      config
    }))
    .catch(next);
}

function get(req, res, next) {
  const configKey = req.params.key;
  let configId;

  Config.findOne({ key: configKey })
    .then(config => {
      configId = config.id;
      return config;
    })
    .then(config => res.json({
      ok: true,
      message: `Config found`,
      config
    }))
    .catch(next);
}

function put(req, res, next) {
  const configKey = req.params.key;
  const props = req.body;
  let configId;

  Config.findOne({ key: configKey })
    .then(config => {
      if (config === undefined) return Config.create({ key: configKey, ...props });
      configId = config.id;
      return Config.update(config.id, props);
    })
    .then(config => res.json({
      ok: true,
      message: `Config updated`,
      config
    }))
    .catch(next);
}

function del(req, res, next) {
  const configKey = req.params.key;
  let configId;

  Config.findOne({ key: configKey })
    .then(config => {
      configId = config.id;
      return Config.destroy(config.id);
    })
    .then(deleteCount => res.json({
      ok: true,
      message: `Config deleted`,
      deleteCount
    }))
    .catch(next);
}

router.route('/config')
  .get(list);

router.route('/config/:key')
  .post(post)
  .get(get)
  .put(put)
  .delete(del);

module.exports = router;
