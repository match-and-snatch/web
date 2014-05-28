# Once clicked, renders HTML received by link href into @$target
# @data use_anchor [true, false, null] if true then sets hash on click
# @data target [String] Target container identifier
class bud.widgets.AjaxLink extends bud.Widget
  @SELECTOR: '.AjaxLink'

  initialize: ->
    @href       = @$container.attr('href')
    @hash       = @href #.replace(/^\//, '')
    @$target    = bud.get(@$container.data('target')) || @$container
    @use_anchor = @data('use_anchor')
    @default    = @data('default')

    @location_changed()
    bud.sub('window.hashchange', @location_changed) if @use_anchor

    @$container.click @link_clicked

  location_changed: =>
    if @use_anchor
      if "##{@hash}" == window.location.hash
        @render_path(@href)
      else if _.isEmpty(window.location.hash) && @default
        window.location.hash = @hash
      else
        @$container.removeClass('active pending')

  link_clicked: =>
    if "##{@hash}" != window.location.hash
      $(bud.widgets.AjaxLink.SELECTOR).removeClass('active pending')

    if @use_anchor
      window.location.hash = @hash
    else
      @render_path(@href)

    return false

  make_active: ->
    @$container.removeClass('pending')
    @$container.addClass('active')

  render_path: (request_path) ->
    @$container.addClass('pending')
    @$target.addClass('pending')
    bud.Ajax.get(request_path, {}, {success: @render_page, replace: @replace_page})

  render_page: (response) =>
    @make_active()
    bud.replace_html(@$target, response['html'])
    @$target.removeClass('pending')
    @$target.show()

  replace_page: (response) =>
    @make_active()
    bud.replace_container(@$target, response['html'])
    @$target.removeClass('pending')
    @$target.show()
