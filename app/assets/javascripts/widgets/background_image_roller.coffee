class bud.widgets.BackgroundImageRoller extends bud.Widget
  @SELECTOR: '.BackgroundImageRoller'

  initialize: ->
    @edit_mode = false
    @$container.text('Scroll Image')

    @$container.on('click', =>
      # target can be replased
      @$target = bud.get(@$container.data('target'))
      @edit_mode = !@edit_mode

      if @edit_mode
        @$container.text('Save Position')
        @prepare_target()
      else
        @$container.text('Scroll Image')
        position = @$target.scrollTop()
        @restore_target()
        bud.pub('cover.scroll', [position])
        @save_position(position)

    )

  prepare_target: ->
    @append_img_to_target()

  restore_target: ->
    @remove_scroll_from_target()
    @remove_image()

  remove_scroll_from_target: ->
    @$target.css('overflow-y', 'hidden')

  remove_image: ->
    @img.remove();

  append_img_to_target: ->
    @img = document.createElement('img')
    @img.src = @$target.data('background_image_url')
    $(@img).load(=>
      @init_vertical_scroll_on_target()
    )
    @$target.append(@img)

  init_vertical_scroll_on_target: =>
    @$target.css('overflow-y', 'scroll')
    position = Math.abs(parseInt(@$target.css('background-position-y')))
    @$target.scrollTop(position)

  save_position: (position)->
    request = new bud.Ajax(@$container.data('action'), {cover_picture_possition: position} )
    request.perform_request('PUT')