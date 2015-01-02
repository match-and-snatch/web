# Toggles container visibility once target visibility is changed
class bud.widgets.ToggleListener extends bud.Widget
  @SELECTOR: '.ToggleListener'

  initialize: ->
    @$target = @get_target()
    @syncronious_visibility = @$container.is(':visible') == @$target.is(':visible')
    @$target.on('toggle', @on_target_toggle)

  on_target_toggle: =>
    @$container.toggle((@syncronious_visibility && @$target.is(':visible')) ||
                      (!@syncronious_visibility && !@$target.is(':visible')))
