# Toggles target's visibility.
class bud.widgets.Toggler extends bud.Widget
  @SELECTOR: '.Toggler'

  initialize: ->
    @$target = @get_target() || @$container
    @$container.click @on_click

  on_click: =>
    @toggle()

    if @$target.is(':visible')
      @$target.find('textarea,input:first').focus()

    return false if @$container.is('a')
    return true

  toggle: ->
    @$target.toggle()
