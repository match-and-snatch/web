# Acts as a simple form
# Posts data attributes to the URL defined by link href
class bud.widgets.AjaxFormLink extends bud.Widget
  @SELECTOR: '.AjaxFormLink'

  initialize: ->
    @url = @$container.attr('href')
    @event = @$container.data('event')
    @data = @$container.data()
    @$container.click @link_clicked

  target: ->
    bud.get(@$container.data('target')) || @$container

  link_clicked: =>
    return false if @$container.hasClass('pending')

    if @$container.data('confirmation')
      bud.confirm 'Are you sure?', @perform_submit
    else
      @perform_submit()

    return false

  perform_submit: =>
    @data['jsWidget'] = undefined
    @data['js-widget'] = undefined

    @$container.removeClass('active')
    @$container.addClass('pending')

    bud.pub(@event, [@]) if @event
    bud.Ajax.post(@url, @data, {success: @render_link, replace: @on_replace})

  render_link: (response) =>
    @$container.removeClass('pending')
    @$container.addClass('active')
    bud.replace_html(@target(), response)

  on_replace: (response) =>
    @$container.removeClass('pending')
    @$container.addClass('active')
    bud.replace_container(@target(), response)
