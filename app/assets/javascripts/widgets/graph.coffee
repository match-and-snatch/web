class bud.widgets.Graph extends bud.Widget
  @SELECTOR: '.Graph'

  initialize: ->
    @data = @$container.data('data')
    @data_label = @$container.data('data_label') || 'Subscriptions'
    bud.Ajax.getScript('//cdnjs.cloudflare.com/ajax/libs/d3/3.4.5/d3.min.js').done(@on_d3_loaded)
    bud.Ajax.getScript('//cdnjs.cloudflare.com/ajax/libs/rickshaw/1.4.6/rickshaw.min.js').done(@on_rickshaw_loaded)

  on_d3_loaded: =>
    @d3_loaded = true

    if @rickshaw_loaded
      @init_graph()

  on_rickshaw_loaded: =>
    @rickshaw_loaded = true

    if @d3_loaded
      @init_graph()

  init_graph: ->
    @$container.empty()

    graph = new Rickshaw.Graph( {
      element: @$container[0],
      renderer: 'area',
      stroke: true,
      interpolation: 'linear',
      series: [{
        color: 'rgba(59,159,209,0.3)',
        stroke: '#3b9fd1',
        data: @data,
        name: @data_label
      }]
    })
    hoverDetail = new Rickshaw.Graph.HoverDetail( {
      graph: graph,
      xFormatter: (x) ->
        new Date(x * 1000).toDateString();
      yFormatter: (y) ->
        y
    })
    graph.render()

    format = (d) ->
      d = new Date(d)
      return d3.time.format("%c")(d)

    axes_x = new Rickshaw.Graph.Axis.Time( {
      graph: graph,
      tickFormat: format
    })
    axes_x.render()
    axes_y = new Rickshaw.Graph.Axis.Y( {
      graph: graph
    })
    axes_y.render()
