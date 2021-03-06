class bud.widgets.AudioPlayer extends bud.Widget
  @SELECTOR: '.AudioPlayer'

  initialize: ->
    super
    @id = @$container.attr('id')
    data = @$container.data()

    @file        = data['file']
    @original    = data['original'] || @file
    @width       = data['width'] || '585'
    @height      = data['height'] || '30'
    @primary     = data['primary'] || 'flash'
    @skin        = data['skin'] || 'bekle'

    bud.Ajax.getScript(window.bud.config.jwplayer.script_path).done(@on_script_loaded)
    bud.sub('player.play', @stop)

  on_play: =>
    bud.pub('player.play', [@])

  destroy: ->
    bud.unsub('player.play', @stop)

  stop: (e, player) =>
    if player != @ && @player
      @player.stop()

  on_script_loaded: =>
    @player = jwplayer(@id).setup({
      playlist: [{
        sources: [{file: @file}, {file: @original}]
      }],
      width: @width,
      height: @height,
      primary: @primary,
      skin: @skin
    })
    @player.onPlay(@on_play)
