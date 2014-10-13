class map.MilestoneView extends Backbone.View
  
  className: -> "milestone " + @model.get('state')
  initialize: -> @model.set_position(@model.collection.origin())

  render: ->
    # Go through each row, if it has children, see if the position of this view
    # would overlap with the last child of the row.
    content = JST['templates/milestone'](@model.toJSON())
    @$el.html content
    @$el.css({width:@model.get('width'),left:@model.get('left')})
    drop = new Drop
      target: @$el[0]
      classes: 'drop-theme-arrows'
      content: @model.formatted_description()
      position: 'bottom center'
      openOn: 'hover'
      constrainToWindow: true
    @