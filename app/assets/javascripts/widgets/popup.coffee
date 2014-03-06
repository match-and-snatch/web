class bud.widgets.Popup extends bud.Widget
  @SELECTOR: '.Popup'

  initialize: ->
    @identifier = @$container.data('identifier')

    # Binds on other popups
    bud.sub("popup.show", @autoclose)

    # Binds on button click
    bud.sub("popup.toggle.#{@identifier}", @toggle)

    # Move into proper HTML position
    @$container.appendTo($('body'))

  # Closes when other popup gets opened
  autoclose: (e, widget) => @hide() if widget != @

  # Toggles visibility on trigger click
  toggle: => if @$container.is(':visible') then @hide() else @show()

  autoplace: ->
    @$container.css('margin-left', "-#{@width()/2}px")
    @$container.css('margin-top', "-#{@height()/2}px")

  show: =>
    # Close other popups
    bud.pub("popup.show", [@]);

    # Show this popup
    @$container.show()
    @autoplace()

    # Show overlay
    bud.pub("popup.show.overlay");

  hide: =>
    @$container.hide()
    bud.pub("popup.hide");

  width: -> @$container.outerWidth()
  height: -> @$container.outerHeight()
