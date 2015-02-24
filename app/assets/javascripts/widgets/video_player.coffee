class bud.widgets.VideoPlayer extends bud.Widget
  @SELECTOR: '.VideoPlayer'

  initialize: ->
    super
    @id = @$container.attr('id')
    data = @$container.data()

    @file        = data['file']
    @hd_file     = data['hdfile']
    @playlist    = data['playlist']
    @original    = data['original']
    @image       = data['image']
    @width       = data['width'] || '585'
    @height      = data['height'] || '330'
    @aspectratio = data['aspectratio'] || '16:9'
    @primary     = data['primary'] || 'flash'
    @skin        = data['skin'] || 'bekle'

    bud.Ajax.getScript(window.bud.config.jwplayer.script_path).done(@on_script_loaded)
    bud.sub('player.play', @stop)

  destroy: -> bud.unsub('player.play', @stop)
  on_play: => bud.pub('player.play', [@])

  stop: (e, player) =>
    if player != @ && @player
      @player.stop()

  on_script_loaded: =>
    @player = jwplayer(@id).setup({
      sources: @sources(),
      width: @width,
      image: @image,
      height: @height,
      aspectratio: @aspectratio,
      primary: @primary,
      androidhls: true
      skin: @skin
    });
    @player.onPlay(@on_play)

  sources: ->
    if @playlist
      [{file: @playlist, image: @image}, {file: @original, image: @image}]
    else
      if @hd_file
        [
          {file: @file, label: 'low', default: false},
          {file: @hd_file, label: 'HD', default: true}
        ]
      else
        [{file: @file, image: @image}, {file: @original, image: @image}]
