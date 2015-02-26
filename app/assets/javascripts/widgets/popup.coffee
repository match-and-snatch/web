class bud.widgets.Popup extends bud.Widget
  @SELECTOR: '.Popup'

  initialize: ->
    @identifier = @$container.data('identifier')

    # Binds on other popups
    bud.sub("popup.show", @autoclose)

    # Binds on button click
    bud.sub("popup.toggle.#{@identifier}", @toggle)

    # Binds on refresh position
    bud.sub("popup.autoplace.#{@identifier}", @autoplace)

    # Move into proper HTML position
    @$container.appendTo($('body'))

  destroy: ->
    bud.unsub("popup.show", @autoclose)
    bud.unsub("popup.toggle.#{@identifier}", @toggle)
    bud.unsub("popup.autoplace.#{@identifier}", @autoplace)
    clearInterval(@autoplacer) if @autoplacer

  # Closes when other popup gets opened
  autoclose: (e, widget) => @hide() if widget != @

  # Toggles visibility on trigger click
  toggle: => if @$container.is(':visible') then @hide() else @show()

  autoplace: =>
    window_height = $(window).height()
    window_width = $(window).width()

    popup_width = @width()
    if Math.abs(@current_popup_width - popup_width) > 1
      @current_popup_width = popup_width

      left_margin = (if popup_width > window_width then window_width else popup_width) / 2
      @$container.css('margin-left', "-#{left_margin}px")

    popup_height = @height()
    if Math.abs(@current_popup_height - popup_height) > 1
      @current_popup_height = popup_height

      unless bud.is_mobile.any()
        top_margin = (if popup_height > window_height then window_height else popup_height) / 2
        @$container.css('margin-top', "-#{top_margin}px")

  show: =>
    @current_popup_height = 0
    @current_popup_width = 0

    # Close other popups
    bud.pub("popup.show", [@]);

    # Show this popup
    @$container.css('position', 'absolute').css('top', window.scrollY + 2) if bud.is_mobile.any()
    @$container.show()
    @autoplace()

    # Show overlay
    bud.pub("popup.show.overlay");
    @$container.find('input:first').focus()
    @autoplacer = setInterval(@autoplace, 200)

  hide: =>
    @$container.css('position', 'fixed')
    @$container.hide()
    bud.pub("popup.hide")
    clearInterval(@autoplacer) if @autoplacer

  width: -> @$container.outerWidth()
  height: -> @$container.outerHeight()
