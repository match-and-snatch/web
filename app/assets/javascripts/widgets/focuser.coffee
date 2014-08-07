class bud.widgets.Focuser extends bud.Widget
  @SELECTOR: '.Focuser'

  initialize: ->
    @$target = bud.get(@$container.data('target'))
    @$container.click @on_click
    
  on_click: =>
    $('html, body').animate
      scrollTop: @$target.offset().top - 50
    , 500

    @$target.focus()
    return !@$container.is('a')
