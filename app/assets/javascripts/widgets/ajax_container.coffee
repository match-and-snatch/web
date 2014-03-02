class bud.widgets.AjaxContainer extends bud.Widget
  @SELECTOR: '.AjaxContainer'

  initialize: ->
    request_path = @$container.data('url')
    @render_path(request_path) if request_path
    @$container.find('a').click @link_clicked

  link_clicked: (e) =>
    link = $(e.currentTarget)
    @render_path(link.attr('href'))
    return false

  render_path: (request_path) ->
    @$container.addClass('pending')
    bud.Ajax.get(request_path, {}, {success: @render_page})

  render_page: (response) =>
    bud.replace_html(@$container, response['html'])
    @$container.removeClass('pending')
    # delete @ :)
