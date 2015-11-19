#= require ./ajax_container

class bud.widgets.PostsContainer extends bud.widgets.AjaxContainer
  @SELECTOR: '.PostsContainer'

  initialize: ->
    @pending = true
    super
    @ajaxify_links = false
    $(window).scroll @on_scroll
    @last_post_id = null
    @page = 1
    @q = null
    @disabled = false
    bud.sub('search.changed', @on_search_changed)

  destroy: ->
    bud.unsub('search.changed', @on_search_changed)

  on_search_changed: (e, q) =>
    @page = 2
    @q = q

  on_scroll: =>
    return if @disabled || @pending

    docViewTop = $(window).scrollTop()
    docViewBottom = docViewTop + $(window).height()

    elTop = @$container.offset().top
    elBottom = elTop + @$container.height()

    if docViewBottom >= elBottom - 40
      @pending = true
      @render()

  on_response_received: (response) =>
    super
    @last_post_id = response['last_post_id']
    @page += 1
    @disabled = !!!@last_post_id
    @pending = false

  request_params: ->
    result =
      last_post_id: @last_post_id
      page: @page
    unless _.isEmpty(@q)
      result['q'] = @q
    result

  init_links: -> true
