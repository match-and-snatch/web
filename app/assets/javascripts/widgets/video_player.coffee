class bud.widgets.VideoPlayer extends bud.Widget
  @SELECTOR: '.VideoPlayer'
  initialize: ->
    super
    bud.Ajax.getScript(window.bud.config.flow_player.script_path).done(@on_script_loaded)

  on_script_loaded: =>
    @$container.flowplayer(window.bud.config.flow_player.swf_path, window.bud.config.flow_player.settings)
