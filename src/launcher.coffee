# launcher.coffee
# entry point of the app
# Copyright (c) 2015 Lu Wang <coolwanglu@gmail.com>

app = require 'app'
# remote = require "remote"
Menu = require "menu"
BrowserWindow = require 'browser-window'

process.on 'uncaughtException', (error={}) ->
  console.log error.message  if error.message?
  console.log error.stack  if error.stack?

# TODO: Multi page app.
app.on 'window-all-closed', -> app.quit()

newNvim = ->
  win = new BrowserWindow width: 800, height: 600, show: false
  win.loadUrl 'file://' + __dirname + '/nvim.html'
  win.webContents.on "did-finish-load", win.show.bind(win)
  win

handlePaste = ->
  win = BrowserWindow.getFocusedWindow()

template = [
  {
    label: "Neovim"
    submenu: [
      {label: "Quit", accelerator: "Command+Q", click: app.quit}
    ]
  },
  {
    label: "File"
    submenu: [
      {label: "New", accelerator: "Command+N", click: newNvim}
    ]
  },
  {
    label: "Edit"
    submenu: [
      {label: "Paste", accelerator: "Command+V", click: handlePaste}
    ]
  }
]

menu = Menu.buildFromTemplate template

win = null
app.on 'ready', ->
  win = newNvim()
  Menu.setApplicationMenu menu
  # win = new BrowserWindow width: 800, height: 600
  # win.loadUrl 'file://' + __dirname + '/nvim.html'
