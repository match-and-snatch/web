class bud.widgets.VideoPlayer extends bud.Widget
  @SELECTOR: '.VideoPlayer'

  initialize: ->
    super
    @id = @$container.attr('id')
    data = @$container.data()

    @file        = data['file']
    @original    = data['original'] || @file
    @image       = data['image']
    @width       = data['width'] || '585'
    @height      = data['height'] || '330'
    @aspectratio = data['aspectratio'] || '16:9'
    @primary     = data['primary'] || 'flash'
    @skin        = data['skin'] || 'bekle'

    bud.Ajax.getScript(window.bud.config.jwplayer.script_path).done(@on_script_loaded)

  on_script_loaded: =>
    jwplayer(@id).setup({
      playlist: [{
        sources: [{file: @file}, {file: @original}],
        image: @image
      }],
      width: @width,
      height: @height,
      aspectratio: @aspectratio,
      primary: @primary,
      skin: @skin
    })
