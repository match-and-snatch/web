class bud.widgets.BackgroundImageShower extends bud.Widget
  @SELECTOR: '.BackgroundImage'

  initialize: ->
    @url = @$container.data('background_image_url')
    bud.sub('cover.scroll', @on_cover_scroll)
    @$container.css('background', "url(#{@url}) no-repeat center -#{@$container.data('position')}px")


   on_cover_scroll: (e, position) =>
    @$container.css('background-position-y', -Math.abs(position))