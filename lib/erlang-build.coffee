{MessagePanelView, LineMessageView, PlainMessageView} = require 'atom-message-panel'

module.exports =
  messagePanelView: null

  initialize: (serializeState) ->
    atom.workspaceView.command "erlang-build:compile", =>
      @compile()


  activate: (state) ->
    @messagePanelView = new MessagePanelView
      title: '<span class="icon-diff-added"></span> erlang-build'
      rawTitle: true
    @messagePanelView.attach()

  deactivate: ->

  serialize: ->

  renderMessages: ->

  compile: ->
