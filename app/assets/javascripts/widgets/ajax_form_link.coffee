# Acts as a simple form
# Posts data attributes to the URL defined by link href
class bud.widgets.AjaxFormLink extends bud.Widget
  @SELECTOR: '.AjaxFormLink'

  initialize: ->
    @url = @$container.attr('href')
    @data = @$container.data()
    @$container.click @link_clicked

  link_clicked: =>
    @data['jsWidget'] = undefined
    @data['js-widget'] = undefined
    @$container.removeClass('active')
    @$container.addClass('pending')
    console.log(@url, @data)
    bud.Ajax.post(@url, @data, {success: @render_link})
    return false

  render_link: (response) =>
    @$container.removeClass('pending')
    @$container.addClass('active')
    bud.replace_html(@$container, response['html'])
