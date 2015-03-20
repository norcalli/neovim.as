# nvim.coffee
# communicate with neovim process
# Copyright (c) 2015 Lu Wang <coolwanglu@gmail.com>

child_process = require 'child_process'
Session = require 'msgpack5rpc'
remote = require 'remote'
UI = require './ui'
config = require './config'
{Definer, suggestCompletions, monospacedFonts} = require "./helpers"

class NVim
  constructor: (args) ->
    @ui = new UI(config.row, config.col)

    # Atom Shell apps are run as 'Atom <path> <args>'
    # might need a better way to locate the arguments
    # nvim_args = ['--embed'].concat remote.process.argv[3..]
    nvim_args = ['--embed'].concat args

    @nvim_process = child_process.spawn 'nvim', nvim_args, stdio: ['pipe', 'pipe', process.stderr]
    # console.log 'child process spawned: ' + @nvim_process.pid

    @nvim_process.on 'close', =>
      # console.log 'child process closed'
      @session.detach()
      # TODO: Multi page app.
      remote.getCurrentWindow().close()
      # remote.require('app').quit()

    @session = new Session
    @session.attach @nvim_process.stdin, @nvim_process.stdout
    @session.on 'notification', (method, args) =>
      @ui.handle_redraw args if method == 'redraw'

    options = ["size.row", "size.col", "load", "save", "font", "cursor.blink"].join "\n"
    good_font_sizes = [8..16].map((x) -> "#{x}px").join("\n")

    @session.on 'request', (method, args, resp) =>
      args = args[0]
      # resp.send
      switch method
        when "gui-config-complete"
          [base, cmdline, idx] = (x.toString() for x in args)
          parts = cmdline[..+idx].split(/\ +/)
          resp.send switch
            when parts.length == 2 then options
            when parts.length == 3
              switch parts[1]
                when "font" then good_font_sizes
                else true
            when parts.length >= 4
              switch parts[1]
                when "font" then monospacedFonts
                else true
            else true
          # # console.log util.inspect [fragment, ().length, idx]
        when "gui-config"
          option = args[0].toString()
          arg = args[1..].join(" ")
          switch option
            when "size.row"
              if not arg
                resp.send ""+config.row, true
              else
                config.row = +arg
                redraw()
                resp.send(true)
            when "size.col"
              if not arg
                resp.send ""+config.col, true
              else
                config.col = +arg
                redraw()
                resp.send(true)
            when "cursor.blink"
              config.blink_cursor = if args.length == 1
                !config.blink_cursor
              else
                Boolean(arg)
              @ui.init_cursor()
              resp.send(true)
            when "font"
              if not arg
                # TODO: How to send as a regular message, not an error?
                resp.send(config.font, true)
              else
                config.font = arg
                # console.log "setting font to '#{config.font}'"
                redraw()
                resp.send(true)
            when "load"
              config.reload()
              redraw()
              resp.send(true)
            when "save"
              config.save()
              resp.send(true)
            else resp.send "Invalid option '#{option}'. Valid: [#{options.replace(/\n/g, ", ")}]", true
        else resp.send("Invalid method #{method}", true)

    definer = new Definer()
    definer
      .func "GuiConfigComplete", "gui-config-complete"
      .comm "GuiConfig", "gui-config", 1, nargs: '+', complete: "custom,GuiConfigComplete"
      .send @session

    @session.request 'ui_attach', [config.col, config.row, true], =>
      @ui.on 'input', (e) =>
        @session.request 'vim_input', [e], ->
      @ui.on 'resize', (col, row) =>
        @session.request 'ui_try_resize', [col, row], ->

    redraw = =>
      @ui.init_font()
      @ui.init_cursor()
      @ui.emit "resize", config.col, config.row
      @ui.emit "input", "<C-l>"

module.exports = NVim
