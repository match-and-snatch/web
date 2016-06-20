#= require ./ajax_container

class bud.widgets.PostsContainer extends bud.widgets.AjaxContainer
  @SELECTOR: '.PostsContainer'

  initialize: ->
    @pending = true
    @current_page = 0
    super
    @ajaxify_links = false
    $(window).scroll @on_scroll
    @q = null
    @disabled = false
    bud.sub('search.changed', @on_search_changed)
    bud.sub('search.finished', @on_search_finished)
    bud.sub('post.toggle.pinned', @reload)

  destroy: ->
    bud.unsub('search.changed', @on_search_changed)
    bud.unsub('search.finished', @on_search_finished)
    bud.unsub('post.toggle.pinned', @reload)

  on_search_changed: (e, q) =>
    @$container.addClass('pending')
    @pending = true
    @current_page = 1
    @q = q

  on_search_finished: =>
    @$container.removeClass('pending')
    @pending = false

  on_scroll: =>
    return if @disabled || @pending

    docViewTop = $(window).scrollTop()
    docViewBottom = docViewTop + $(window).height()

    elTop = @$container.offset().top
    elBottom = elTop + @$container.height()

    if docViewBottom >= elBottom
      @pending = true
      @render()

  reload: =>
    @$container.addClass('pending')
    @pending = true
    @current_page = 0
    bud.clear_html(@$container)
    @render()

  on_response_received: (response) =>
    super
    @current_page += 1
    @disabled = !response['has_more']
    @pending = false

  request_params: ->
    result =
      page: @current_page + 1
    unless _.isEmpty(@q)
      result['q'] = @q
    result

  init_links: -> true
