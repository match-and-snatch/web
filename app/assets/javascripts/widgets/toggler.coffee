# Toggles target's visibility.
class bud.widgets.Toggler extends bud.Widget
  @SELECTOR: '.Toggler'

  initialize: ->
    @$target = bud.get(@$container.data('target')) || @$container
    @$container.click @on_click

  on_click: =>
    @$target.toggle()
    return false if @$container.is('a')
    return true
