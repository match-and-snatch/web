# iPad Widget
# Shows target on hover, on click
# Hides target on mouseout, on click
class bud.widgets.Hover extends bud.Widget
  @SELECTOR: '.Hover'

  initialize: ->
    @$target = bud.get(@$container.data('target')) || @$container
    @$container.click @on_hover

  on_hover: (e) =>
    e.stopPropagation()
    @$target.show()
    @toggle_classes()

  toggle_classes: ->
    if @$target.is(':visible')
      @$container.addClass('shows')
    else
      @$container.addClass('hides')
