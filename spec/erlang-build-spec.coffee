{WorkspaceView} = require 'atom'
path = require 'path'
ErlangBuild = require '../lib/erlang-build'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "ErlangBuild", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView()
    activationPromise = (atom.packages.activatePackage 'erlang-build')

  describe "when erlang-build:compile is triggered", ->
    it "displays a message panel", ->
      (expect (atom.workspaceView.find '.am-panel')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'erlang-build:compile'

      waitsForPromise ->
        activationPromise

      runs ->
        (expect (atom.workspaceView.find '.am-panel')).toExist()
