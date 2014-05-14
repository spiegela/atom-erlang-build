{MessagePanelView, LineMessageView, PlainMessageView} = require 'atom-message-panel'
{spawn} = require 'child_process'
CompileStatus = require './compile-status'

module.exports =
  messagePanelView: null

  compile: ->
    process.env.PATH = process.env.PATH + ':/usr/local/bin'
    proc = spawn '/usr/local/bin/rebar', ['compile'], cwd: atom.project.path
    @status ||= new CompileStatus
    proc.stdout.pipe @status
    proc.stdout.on 'end',  () =>
      for app, errors of @status.errors
        if errors.length > 0
          @displayMessage "Application: #{app} has compilation errors:"
          @displayMessage error for error in errors
        else
          @displayMessage "Application: #{app} compiled successfully."

      @messagePanelView.attach()

  activate: (state) ->
    @messagePanelView = new MessagePanelView
      title: '<span class="icon-diff-added"></span> erlang-build'
      rawTitle: true
    atom.workspaceView.command "erlang-build:compile", =>
      @compile()
  deactivate: ->

  serialize: ->

  renderMessages: ->

  resetPanel: ->
    @messagePanelView.close()
    @messagePanelView.clear()

  displayMessage: (msg) ->
    if typeof msg == "string"
      @messagePanelView.add new PlainMessageView message: msg
    else if typeof msg == "object"
      @messagePanelView.add new LineMessageView msg
    else
      console.log typeof msg
