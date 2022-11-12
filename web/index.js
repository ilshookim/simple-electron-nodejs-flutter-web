`use strict`;

const Net = require(`net`);
const Path = require(`path`);

// Modules to logging
const logger = require('electron-log');

// Modules to control application life and create native browser window
const { app, screen, dialog, BrowserWindow, Menu } = require(`electron`);

// Remove the application menu.
Menu.setApplicationMenu(null);

// Keep a global reference of the window object, if you don`t, the window will
// be closed automatically when the JavaScript object is garbage collected.
let mainWindow;

function createWindow() {
  const recalc = false, ratio = 0.75;
  const { width, height } = screen.getPrimaryDisplay().workAreaSize;
  const [recalcWidth, recalcHeight] = recalc ? [ratio * width, ratio * height] : [800, 600];
  logger.info(`createWindow ratio=${ratio}, width=${recalcWidth}, height=${recalcHeight} in ${__dirname}`);

  // Create the browser window.
  mainWindow = new BrowserWindow({
    width: recalcWidth,
    height: recalcHeight,
    webPreferences: {
      nodeIntegration: true,
      preload: Path.join(__dirname, `preload.js`)
    }
  });

  // and load the index.html of the app.
  mainWindow.loadFile(`index.html`);

  // Open the DevTools.
  // mainWindow.webContents.openDevTools();

  // Emitted when the window is closed.
  mainWindow.on(`closed`, function () {
    // Dereference the window object, usually you would store windows
    // in an array if your app supports multi windows, this is the time
    // when you should delete the corresponding element.
    mainWindow = null;
  });
}

// Quit when all windows are closed.
app.on('window-all-closed', () => {
  logger.info('quit - all windows was closed');
  app.quit();
})

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on('ready', async () => {
  const port = process.env.PORT || 8090;
  const portAlreadyUsedIn = await checkPort(port) !== 'closed';
  if (portAlreadyUsedIn) {
    logger.info('quit - middleware port is already used in');
    dialog.showMessageBoxSync({
      type: 'warning',
      message: 'This application cannot be run multiple times',
      detail: `Middleware port ${port} is already used in`});
    app.quit();
    return;
  }
  require(`./middleware`);
  createWindow();
})

// In this file you can include the rest of your app`s specific main process
// code. You can also put them in separate files and require them here.

async function checkPort(port, host = `localhost`, timeout = 400) {
  let connectionRefused = false;

  let socket = new Net.Socket();
  let status = null;
  let error = null;

  return new Promise((resolve, reject) => {
    socket.on(`connect`, function onOpen() {
      status = `open`;
      socket.destroy();
    });

    socket.setTimeout(timeout)
    socket.on(`timeout`, function onTimeout() {
      status = `closed`;
      error = new Error(`Timeout (${timeout}ms) occurred waiting for ${host}:${port} to be available`);
      socket.destroy();
    });

    socket.on(`error`, function onError(exception) {
      if (exception.code !== `ECONNREFUSED`) exception = exception;
      else connectionRefused = true;
      status = `closed`;
    });

    socket.on(`close`, function onClose(exception) {
      if (exception && !connectionRefused) { error = error || exception; } else { error = null; }
      if (error) reject(error); else resolve(status);
    });

    socket.connect(port, host);
  });
}
