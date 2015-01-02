# Toggles popup visibility
class bud.widgets.PopupTrigger extends bud.Widget
  @SELECTOR: '.PopupTrigger'

  initialize: ->
    @target = @$container.data('target')
    @$container.click @on_click
    @$container.on 'touchstart', @on_click

  on_click: =>
    bud.pub("popup.toggle.#{@target}")
    return false if @$container.is('a')
    return true
