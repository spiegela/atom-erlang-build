{View} = require 'atom'

module.exports =
class ErlangBuildView extends View
  @content: ->
    @div class: 'erlang-build overlay from-top', =>
      @div "The ErlangBuild package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    atom.workspaceView.command "erlang-build:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "ErlangBuildView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
