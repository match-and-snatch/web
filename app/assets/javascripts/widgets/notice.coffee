class bud.widgets.Notice extends bud.Widget
  @SELECTOR: '.Notice'

  initialize: ->
    @timeout = @$container.data('timeout')
    @countdown = @timeout
    @$target = bud.get(@$container.data('target'))
    @$counter = bud.get(@$container.data('counter-target'))
    @$counter.html(@timeout)

    bud.sub('notice.show', @on_show)
    bud.sub('notice.hide', @on_hide)

    @$container.mouseover @pause
    @$container.mouseleave @start

  destroy: ->
    bud.unsub('notice.show', @on_show)
    bud.unsub('notice.hide', @on_hide)

  start: =>
    unless @has_links()
      @interval = setInterval =>
        @countdown -= 1

        if @countdown >= 0
          @$counter.html(@countdown)
        else
          bud.pub('notice.hide')
      , 1000

  pause: =>
    clearInterval(@interval) if @interval

  on_hide: =>
    @countdown = @timeout
    @$container.stop(true, true).fadeOut({queue: false}).slideUp()
    clearInterval(@interval)

  on_show: (e, text) =>
    clearInterval(@interval) if @interval

    @countdown = @timeout

    @$counter.html(@countdown)
    bud.replace_html(@$target, text)

    @$container.removeClass('hidden')
    @$container.css('display', 'none')
    @$container.stop(true, true).fadeIn({queue: false}).css('display', 'none').slideDown()

    if @has_links()
      @$counter.html('')
    else
      @start()

  has_links: ->
    @$target.find('a').length > 0
