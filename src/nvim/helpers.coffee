
class Definer
  constructor: ->
    @clear()
  clear: =>
    @funcs = []
    @comms = []
  func: (name, handler, sync=true, opts={}) =>
    @funcs.push "'#{handler}', #{+sync}, '#{name}', #{JSON.stringify opts}"
    @
  comm: (name, handler, sync=true, opts={}) =>
    @comms.push "'#{handler}', #{+sync}, '#{name}', #{JSON.stringify opts}"
    @
  send: (session) =>
    session.request 'vim_get_api_info', [], (err, resp) =>
      channel = resp[0]
      f = @funcs.map((x) -> "call remote#define#FunctionOnChannel(#{channel}, #{x})").join(" | ")
      c = @comms.map((x) -> "call remote#define#CommandOnChannel(#{channel}, #{x})").join(" | ")
      # TODO: Let them pass a callback?
      # console.log "#{f} | #{c}"
      session.request 'vim_command', ["#{f} | #{c}"], (err, resp) =>
    @

unless String::startsWith
  Object.defineProperty String::, "startsWith",
    enumerable: false
    configurable: false
    writable: false
    value: (searchString, position) ->
      position = position or 0
      @lastIndexOf(searchString, position) is position

Array::unique = ->
  o = {}
  i = undefined
  l = @length
  r = []
  i = 0
  while i < l
    o[this[i]] = this[i]
    i += 1
  for i of o
    r.push o[i]
  r

{execSync} = require "child_process"
# TODO: What about windows?
# monospacedFonts = execSync "fc-list :spacing=mono:lang=en family", encoding: "utf8"
monospacedFonts = execSync "fc-list :spacing=mono:lang=en family | cut -d, -f1 | sort -u", encoding: "utf8"
monospacedFonts = monospacedFonts.replace(/,.+$/mg, "")
# monospacedFonts = monospacedFonts.trim().split("\n")

finishIfMatch = (frag, check) -> check.substr(frag.length) if check.indexOf(frag) == 0

contains = (needle, stack) -> check.toLocaleLowerCase().indexOf(frag.toLocaleLowerCase()) >= 0

module.exports =
  Definer: Definer
  monospacedFonts: monospacedFonts
  suggestCompletions: (base, options, prefix="") ->
    # (x for x in options if k).filter(Boolean)
    (prefix + finishIfMatch(base, x) for x in options).filter(Boolean)

