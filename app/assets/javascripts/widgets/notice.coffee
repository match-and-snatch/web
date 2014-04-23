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

  start: =>
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
    @$container.slideUp()
    clearInterval(@interval)

  on_show: (e, text) =>
    clearInterval(@interval) if @interval

    @countdown = @timeout

    @$counter.html(@countdown)
    @$target.html(text)

    @$container.removeClass('hidden')
    @$container.css('display', 'none')
    @$container.slideDown()

    @start()
