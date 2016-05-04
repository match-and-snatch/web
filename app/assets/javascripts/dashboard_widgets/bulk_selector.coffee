class bud.widgets.BulkSelector extends bud.Widget
  @SELECTOR: '.BulkSelector'

  initialize: ->
    @$target = @get_target()
    @$container.change @on_change

  on_change: =>
    @$target.prop 'checked', @$container.prop('checked')
