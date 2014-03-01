class bud.widgets.AjaxLink extends bud.Widget
  @SELECTOR: '.AjaxLink'

  initialize: ->
    @$target = $(@$container.data('target'))
    @$container.click @link_clicked

  link_clicked: (e) =>
    link = $(e.currentTarget)
    @render_path(link.attr('href'))
    return false

  render_path: (request_path) ->
    @$target.css('opacity', 0.5)
    bud.Ajax.get(request_path, {}, {success: @render_page})

  render_page: (response) =>
    bud.replace_html(@$target, response['html'])
    @$target.css('opacity', 1.0)
