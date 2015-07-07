class bud.widgets.RadioToggler extends bud.Widget
  @SELECTOR: '.RadioToggler'

  initialize: ->
    $("[name=#{@$container.attr('name')}]").on('change', @on_change)

  on_change: =>
    @get_target().toggle(@$container.is(':checked'))
