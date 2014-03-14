# Clears target container HTML when container is clicked
# @data target [String] Target identifier
class bud.widgets.Cleaner extends bud.Widget
  @SELECTOR: '.Cleaner'

  initialize: ->
    @$target = bud.get(@$container.data('target'))
    @$container.click @on_click

  on_click: => bud.clear_html(@$target)
