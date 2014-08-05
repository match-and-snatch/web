class bud.widgets.Sticker extends bud.Widget
  @SELECTOR: '.Sticker'

  initialize: ->
    @point = @$container.offset().top
    $(window).scroll @on_scroll

  on_scroll: =>
    if $(window).scrollTop() >= @point - 50
      @$container.css
        position: 'fixed'
        top: '50px'
        'z-index': 2
        width: '617px'
    else
      @$container.css
        position: 'relative'
        top: '0px'
        'z-index': 1
