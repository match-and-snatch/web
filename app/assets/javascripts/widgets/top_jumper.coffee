class bud.widgets.TopJumper extends bud.Widget
  @SELECTOR: '.TopJumper'

  # _____PAGE_TOP_____
  # ------------------ 0 <-- opacity
  #
  #        ....
  #
  # ------------------ 0 ~400px start    |  ------ 0    | 0
  #                                      |              |
  # ------------------ 0.5               |  ------ 0.5  | 100
  #                                      |              |
  # ------------------ 1 ~600px end      |  ------ 1    | 200 (gap)
  initialize: ->
    if @$container.data('start')
      @start = parseInt(@$container.data('start'))
      @end   = parseInt(@$container.data('end'))
      @gap   = @end - @start

      $(window).scroll @on_scroll
      @on_scroll()

    @$container.click ->
      window.scrollTo(0, 0)
      false

    @$container.find('a').click ->
      window.scrollTo(0, 0)
      false

  on_scroll: =>
    top = $(window).scrollTop()

    if top < @start
      opacity = 0
    else if top >= @end
      opacity = 1
    else
      opacity = (top - @start) / @gap

    @$container.css('opacity', opacity)

  destroy: ->
    super
    $(window).unbind('scroll', @on_scroll)
