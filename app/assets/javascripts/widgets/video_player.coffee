class bud.widgets.VideoPlayer extends bud.Widget
  @SELECTOR: '.VideoPlayer'
  @SWF_PATH= "//releases.flowplayer.org/5.4.6/flowplayer.swf"
  @FLOWPLAYER_SCRIPT_PATH = "//releases.flowplayer.org/5.4.6/flowplayer.min.js"

  initialize: ->
    super
    bud.Ajax.getScript(@constructor.FLOWPLAYER_SCRIPT_PATH).done(@on_script_loaded)
    @$container.one 'click', @init_and_start_palyer

  init_and_start_palyer: =>
    @$container.flowplayer(swf: bud.widgets.VideoPlayer.SWF_PATH)
      .bind('ready', ->
        $(@).data('flowplayer').play()
      )

  on_script_loaded: =>

