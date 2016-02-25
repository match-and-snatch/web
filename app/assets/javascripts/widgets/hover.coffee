# iPad Widget
# Shows target on hover, on click
# Hides target on mouseout, on click
class bud.widgets.Hover extends bud.Widget
  @SELECTOR: '.Hover'

  initialize: ->
    @$target = bud.get(@$container.data('target')) || @$container
    @url = @data('url')
    @remote_content_loaded = false
    @$container.click @on_hover
    @$container.hover @on_hover
    @$container.mouseleave @on_out
    @$container.find('a').on 'touchstart', @on_link_touch
    @$container.find('a').on 'touchend', @on_out
    bud.sub('document.touchstart', @on_body_touch)

  destroy: ->
    bud.unsub('document.touchstart', @on_body_touch)

  on_body_touch: (e, current_target) =>
    @on_out()

  on_out: =>
    @$target.hide()

  on_hover: (e) =>
    e.stopPropagation()
    @$target.show()
    if @need_remote_content()
      bud.Ajax.get(@url, {}, {success: @render_remote_content})
    true

  on_link_touch: (e) =>
    e.stopPropagation()
    window.location = $(e.currentTarget).attr('href')

  need_remote_content: ->
    @url && !@remote_content_loaded

  render_remote_content: (response) =>
    @remote_content_loaded = true
    bud.replace_html(@$target, response)

