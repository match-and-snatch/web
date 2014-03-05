class bud.widgets.AjaxFormLink extends bud.Widget
  @SELECTOR: '.AjaxFormLink'

  initialize: ->
    @url = @$container.attr('href')
    @data = @$container.data()
    @$container.click @link_clicked

  link_clicked: =>
    @$container.removeClass('active')
    @$container.addClass('pending')
    bud.Ajax.post(@url, @data, {success: @render_link})
    return false

  render_link: (response) =>
    @$container.removeClass('pending')
    @$container.addClass('active')
    bud.replace_html(@$container, response['html'])
