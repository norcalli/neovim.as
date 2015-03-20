# main.coffee
# entry point of the renderer
# Copyright (c) 2015 Lu Wang <coolwanglu@gmail.com>

Nvim = require "./nvim/nvim"
remote = require "remote"

window.onload = ->
  try
    # window.nvim = new (require('./nvim/nvim'))()
    window.nvim = new Nvim remote.process.argv[3..]
  catch error
    win = remote.getCurrentWindow()
    win.setSize 800, 600
    win.center()
    win.show()
    win.openDevTools()
    # console.log error.stack ? error
