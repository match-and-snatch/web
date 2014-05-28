# iPad Widget
# Shows target on hover, on click
# Hides target on mouseout, on click
class bud.widgets.Hover extends bud.Widget
  @SELECTOR: '.Hover'

  initialize: ->
    @$target = bud.get(@$container.data('target')) || @$container
    @$container.click @on_hover
    @$container.find('a').on 'touchstart', @on_link_touch
    @$container.hover @on_hover
    @$container.mouseleave @on_out
    bud.sub('document.touchstart', @on_body_touch)

  on_body_touch: (e, current_target) =>
    @on_out()

  on_out: =>
    @$target.hide()
    @toggle_classes()

  on_hover: (e) =>
    e.stopPropagation()
    @$target.show()
    @toggle_classes()

  on_link_touch: (e) =>
    e.stopPropagation()
    window.location = $(e.currentTarget).attr('href')

  toggle_classes: ->
    if @$target.is(':visible')
      @$container.addClass('shows')
    else
      @$container.addClass('hides')
