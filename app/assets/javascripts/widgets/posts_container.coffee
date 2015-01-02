#= require ./ajax_container

class bud.widgets.PostsContainer extends bud.widgets.AjaxContainer
  @SELECTOR: '.PostsContainer'

  initialize: ->
    @pending = true
    super
    $(window).scroll @on_scroll
    @last_post_id = null
    @q = null
    @disabled = false
    bud.sub('search.changed', @on_search_changed)

  destroy: ->
    bud.unsub('search.changed', @on_search_changed)

  on_search_changed: (e, q) =>
    @q = q

  on_scroll: =>
    return if @disabled || @pending

    docViewTop = $(window).scrollTop();
    docViewBottom = docViewTop + $(window).height();

    elTop = @$container.offset().top
    elBottom = elTop + @$container.height()

    if docViewBottom >= elBottom - 40
      @pending = true
      @render()

  on_response_received: (response) =>
    super
    @last_post_id = response['last_post_id']
    @disabled = !!!@last_post_id
    @pending = false

  request_params: ->
    result = {last_post_id: @last_post_id}
    if !_.isEmpty(@q)
      result['q'] = @q
    result
