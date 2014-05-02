{WorkspaceView} = require 'atom'
ErlangBuild = require '../lib/erlang-build'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "ErlangBuild", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView()
    activationPromise = atom.packages.activatePackage('erlang-build')

  describe "when the erlang-build:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.erlang-build')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'erlang-build:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.erlang-build')).toExist()
        atom.workspaceView.trigger 'erlang-build:toggle'
        expect(atom.workspaceView.find('.erlang-build')).not.toExist()
