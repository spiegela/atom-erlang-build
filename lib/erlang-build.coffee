{MessagePanelView, LineMessageView, PlainMessageView} = require 'atom-message-panel'
{spawn} = require 'child_process'

module.exports =
  messagePanelView: null

  compile: ->
    process.env.PATH = process.env.PATH + ':/usr/local/bin'
    proc = spawn '/usr/local/bin/rebar', ['compile'], cwd: atom.project.path

    proc.stdout.on 'data', (data) =>
      @displayMessage 'COMPILE: ' + data if data?
    proc.stderr.on 'data', (data) =>
      @displayMessage 'COMPILE: ' + data.toString()
    proc.on 'exit', (code) =>
      @displayMessage 'COMPILE: exited with code: ' + code

    @messagePanelView.attach()

  displayMessage: (text) ->
    console.log text
    @messagePanelView.add new PlainMessageView message: text

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
