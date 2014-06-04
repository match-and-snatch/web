#= require widgets/form

class bud.widgets.DialogueForm extends bud.widgets.Form
  @SELECTOR: '.DialogueForm'

  initialize: ->
    super
    @$target = @get_target()
    @$menu_item = @get_target('menu_link')
    @$menu_item.addClass('active')
    @scroll_to_bottom()

  scroll_to_bottom: ->
    @$target.scrollTop(@$target.prop("scrollHeight"))

  on_after: =>
    super
    @$container[0].reset()
    @scroll_to_bottom()

