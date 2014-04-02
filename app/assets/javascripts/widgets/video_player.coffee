class bud.widgets.VideoPlayer extends bud.Widget
  @SELECTOR: '.video_player'
  @SWF_PATH= "http://releases.flowplayer.org/5.4.6/flowplayer.swf"
  @FLOWPLAYER_SCRIPT_PATH = "//releases.flowplayer.org/5.4.6/flowplayer.min.js"

  initialize: ->
    super
    bud.Ajax.getScript(@constructor.FLOWPLAYER_SCRIPT_PATH).done(@on_script_loaded)

  on_script_loaded: =>
    @$container.flowplayer()#{ swf: @constructor.SWF_PATH });

