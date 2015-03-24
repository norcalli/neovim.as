# launcher.coffee
# entry point of the app
# Copyright (c) 2015 Lu Wang <coolwanglu@gmail.com>

app = require 'app'
# remote = require "remote"
Menu = require "menu"
BrowserWindow = require 'browser-window'
dialog = require "dialog"
# FIXME: Can't use this config if it calls remote.
# config = require "./nvim/config"

process.on 'uncaughtException', (error={}) ->
  console.log error.message  if error.message?
  console.log error.stack  if error.stack?

# TODO: Multi page app.
quitting = false
app.on 'window-all-closed', ->
  if quitting
    app.quit()
    quitting = false

tryAppQuit = ->
  quitting = true
  windows = BrowserWindow.getAllWindows()
  return app.quit() if not windows.length
  for bw in windows
    sendCommand bw, "qa"

tryAppQuitSave = ->
  quitting = true
  windows = BrowserWindow.getAllWindows()
  return app.quit() if not windows.length
  for bw in windows
    sendCommand bw, "wall | qa"

newNvim = ->
  win = new BrowserWindow width: 800, height: 600, show: false, frame: false, transparent: true
  # win = new BrowserWindow width: 800, height: 600, frame: false
  win.loadUrl 'file://' + __dirname + '/nvim.html'
  contents = win.webContents
  contents
    .on "did-finish-load", win.show.bind(win)
    .on "will-navigate", (e) -> e.preventDefault()
  win

clipboard = require "clipboard"

toggleFullscreen = ->
  bw = BrowserWindow.getFocusedWindow()
  bw.setFullScreen !bw.isFullScreen()

handlePaste = ->
  BrowserWindow.getFocusedWindow().send "paste", clipboard.readText()

openDevTools = ->
  BrowserWindow.getFocusedWindow().openDevTools()

sendCommand = (bw, cmd) -> bw.webContents.send "command", cmd

command = (cmd) ->
  -> sendCommand BrowserWindow.getFocusedWindow(), cmd

template = [
  {
    label: "Neovim"
    submenu: [
      {label: "Quit", accelerator: "Command+Q", click: tryAppQuit}
      {label: "Save and Quit", accelerator: "Shift+Command+Q", click: tryAppQuitSave}
    ]
  }
  {
    label: "File"
    submenu: [
      {label: "New", accelerator: "Command+N", click: newNvim}
      {label: "Save", accelerator: "Command+S", click: command("w")}
    ]
  }
  {
    label: "Edit"
    submenu: [
      {label: "Paste", accelerator: "Command+V", click: handlePaste}
    ]
  }
  {
    label: "Window"
    submenu: [
      {label: "Close", accelerator: "Command+W", click: command("qa")}
      {label: "Fullscreen", accelerator: "Shift+Command+F", click: toggleFullscreen}
    ]
  }
  {
    label: "Debug"
    submenu: [
      {label: "Dev Tools", accelerator: "Alt+Command+I", click: openDevTools}
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
