ErlangBuildView = require './erlang-build-view'

module.exports =
  erlangBuildView: null

  activate: (state) ->
    @erlangBuildView = new ErlangBuildView(state.erlangBuildViewState)

  deactivate: ->
    @erlangBuildView.destroy()

  serialize: ->
    erlangBuildViewState: @erlangBuildView.serialize()
