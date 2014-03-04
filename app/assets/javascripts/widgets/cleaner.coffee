class bud.widgets.Cleaner extends bud.Widget
  @SELECTOR: '.Cleaner'

  initialize: ->
    @$target = $(@$container.data('target'))
    @$container.click @on_click

  on_click: => bud.clear_html(@$target)
