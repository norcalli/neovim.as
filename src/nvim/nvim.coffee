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

    process.env.PATH += ":/usr/local/bin"
    @nvim_process = child_process.spawn 'nvim', nvim_args, stdio: ['pipe', 'pipe', process.stderr]
    # console.log 'child process spawned: ' + @nvim_process.pid

    @nvim_process.on 'close', =>
      # console.log 'child process closed'
      @session.detach()
      remote.getCurrentWindow().close()

    @session = new Session
    @session.attach @nvim_process.stdin, @nvim_process.stdout
    @session.on 'notification', (method, args) =>
      @ui.handle_redraw args if method == 'redraw'

    @options = ["app.quit_silently", "size.row", "size.col", "load", "save", "font", "cursor.blink"].join "\n"
    good_font_sizes = [8..16].map((x) -> "#{x}px").join("\n")

    guiComplete = (args) =>
      [base, cmdline, idx] = (x.toString() for x in args)
      parts = cmdline[..+idx].split(/\ +/)
      switch
        when parts.length == 2 then return @options
        when parts.length == 3
          switch parts[1]
            when "font" then return good_font_sizes
        when parts.length >= 4
          switch parts[1]
            when "font" then return monospacedFonts
      return true

    guiConfig = (args) =>
      @guiConfig args[0].toString(), args[1..].join(" ")
    new Definer()
      .func "GuiConfigComplete", guiComplete
      .comm "GuiConfig", guiConfig, 1, nargs: '+', complete: "custom,GuiConfigComplete"
      .attach @session

    @session.request 'ui_attach', [config.col, config.row, true], =>
      @ui.on 'input', (e) =>
        @session.request 'vim_input', [e], ->
      @ui.on 'resize', (col, row) =>
        @session.request 'ui_try_resize', [col, row], ->

  redraw: =>
    @ui.init_font()
    @ui.init_cursor()
    @ui.emit "resize", config.col, config.row
    @ui.emit "input", "<C-l>"

  guiConfig: (option, arg) =>
    switch option
      when "size.row"
        throw "#{config.row}" if not arg
        config.row = +arg
        @redraw()
      when "size.col"
        throw "#{config.col}" if not arg
        config.col = +arg
        @redraw()
      when "cursor.blink"
        config.blink_cursor = if not arg then !config.blink_cursor else Boolean(arg)
        @ui.init_cursor()
      when "app.quit_silently"
        config.quit_silently = if not arg then !config.quit_silently else Boolean(arg)
      when "font"
        # TODO: How to send as a regular message, not an error?
        throw "#{config.font}" if not arg
        config.font = arg
        @redraw()
      when "load"
        config.reload()
        @redraw()
      when "save"
        config.save()
      else
        throw "Invalid option '#{option}'. Valid: [#{@options.replace(/\n/g, ", ")}]"

  paste: (text) =>
   @ui.emit "input", "<esc>[200~#{text}<esc>[201~"

  quit: => @command "quit"

  command: (cmd) ->
    @session.request "vim_command", [cmd], (err, resp) =>

module.exports = NVim
