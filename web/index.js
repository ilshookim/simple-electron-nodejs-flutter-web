`use strict`;

const Path = require(`path`);

// Modules to logging
const Logger = require('electron-log');
const [logger] = [Logger];

// Modules to control application life and create native browser window
const { app, screen, BrowserWindow, Menu } = require(`electron`);

// Remove the application menu.
Menu.setApplicationMenu(null);

// Keep a global reference of the window object, if you don`t, the window will
// be closed automatically when the JavaScript object is garbage collected.
let mainWindow;

function createWindow() {
  const recalc = false, ratio = 0.75;
  const { width, height } = screen.getPrimaryDisplay().workAreaSize;
  const [recalcWidth, recalcHeight] = recalc ? [ratio * width, ratio * height] : [1024, 768];
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
  logger.info('quit - all windows was closed')
  app.quit()
})

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on('ready', async () => {
  createWindow()
})

// In this file you can include the rest of your app`s specific main process
// code. You can also put them in separate files and require them here.

require(`./middleware`);
