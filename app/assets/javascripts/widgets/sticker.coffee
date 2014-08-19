class bud.widgets.Sticker extends bud.Widget
  @SELECTOR: '.Sticker'

  initialize: ->
    @sourse_css =
      'position': @$container.css('position')
      'top':      @$container.css('top')
      'z-index':  @$container.css('z-index')
      'width':    @$container.css('width')

    @offset_from_top = @$container.offset().top

    $(window).scroll @on_scroll

  on_scroll: =>
    if $(window).scrollTop() >= @offset_from_top - 50
      @$container.css
        'position': 'fixed'
        'top':      '50px'
        'z-index':  9999
        'width': @sourse_css.width
    else
      @$container.css @sourse_css

