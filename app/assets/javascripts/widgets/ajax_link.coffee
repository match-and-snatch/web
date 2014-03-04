class bud.widgets.AjaxLink extends bud.Widget
  @SELECTOR: '.AjaxLink'

  initialize: ->
    @$target = $(@$container.data('target'))
    @$container.click @link_clicked

  link_clicked: (e) =>
    $(@constructor.SELECTOR).removeClass('active pending')
    @render_path(@$container.attr('href'))
    @$container.addClass('pending')
    return false

  render_path: (request_path) ->
    @$target.addClass('pending')
    bud.Ajax.get(request_path, {}, {success: @render_page})

  render_page: (response) =>
    @$container.removeClass('pending')
    @$container.addClass('active')
    bud.replace_html(@$target, response['html'])
    @$target.removeClass('pending')
    @$target.show()
