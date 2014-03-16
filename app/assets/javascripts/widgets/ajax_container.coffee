# Renders remote URL into html container
# If a link is clicked - container acts as IFrame
#
# @data url [String, null] url to load on widget initialized.
class bud.widgets.AjaxContainer extends bud.Widget
  @SELECTOR: '.AjaxContainer'

  initialize: ->
    @url = @$container.data('url')
    @$container.find('a').click @link_clicked
    @render()

  render: ->
    @render_path(@url) if @url

  link_clicked: (e) =>
    link = $(e.currentTarget)
    @render_path(link.attr('href'))
    return false

  render_path: (request_path) ->
    @$container.addClass('pending')
    callbacks = {success: @render_page, replace: @replace_page, append: @append_page, prepend: @prepend_page, after: @on_response_received}
    bud.Ajax.get(request_path, @request_params(), callbacks)

  append_page: (response) =>
    bud.append_html(@$container, response['html'])

  prepend_page: (response) =>
    bud.prepend_html(@$container, response['html'])

  replace_page: (response) =>
    bud.replace_container(@$container, response['html'])

  render_page: (response) =>
    bud.replace_html(@$container, response['html'])

  on_response_received: (response) =>
    @$container.removeClass('pending')
    unless response['html']
      bud.replace_html(@$container, response)

  request_params: -> {}
