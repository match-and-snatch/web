class bud.widgets.Checkbox extends bud.Widget
  @SELECTOR: '.Checkbox'

  initialize: ->
    @$container.on('click', @clicked)
    @$target = @get_target()
    @$target.on 'change', @redraw
    @redraw()

  redraw: =>
    @$container.toggleClass('checked', @input_checked())

  clicked: =>
    @$target.prop('checked', !@input_checked()).change()
    @redraw()
    true

  input_checked: ->
    @$target.prop('checked')
