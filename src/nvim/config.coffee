# config.coffee
# user configs
# Copyright (c) 2015 Lu Wang <coolwanglu@gmail.com>

remote = require 'remote'
path = require 'path'
cson = require 'cson'
fs = require 'fs'
app = remote.require 'app'

user_config_file_name = path.join app.getPath('userData'), 'config.cson'

# default
Config = ->
  @fg_color = '#000'
  @bg_color = '#fff'
  @row = 80
  @col = 40
  @font = '13px Inconsolata, Monaco, Consolas, \'Source Code Pro\', \'Ubuntu Mono\', \'DejaVu Sans Mono\', \'Courier New\', Courier, monospace'
  # @quit_silently = false
  @blink_cursor = true

Config.prototype =
  save: ->
    # console.log cson.stringify @
    fs.writeFileSync user_config_file_name, cson.stringify(@)
  reload: ->
    changed = false
    try
      user_config = cson.load user_config_file_name
      if user_config not instanceof Error
            for k of config when user_config[k]?
              val = user_config[k]
              changed = true if @[k] != val
              @[k] = val
        return changed

config = new Config()
config.reload()

module.exports = config
