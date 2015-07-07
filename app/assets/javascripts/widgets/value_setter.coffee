class bud.widgets.ValueSetter extends bud.Widget
  @SELECTOR: '.ValueSetter'

  initialize: ->
    @$target = @get_target()
    @$container.on('change', @on_change)
    @on_change()

  on_change: =>
    if @$container.is(':checked')
      @$target.val(@$container.val())
    true
