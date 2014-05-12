classes =
  helpers:
    today: new Date()
    day_width: 25
    time_position: (time,origin) ->
      diff = new Date(time).getTime() - origin
      @days(diff)*@day_width
    set_width: (model) ->
      if model.duration?
        @days(model.duration)*@day_width
      else
        10*@day_width
    days: (time) ->
      int_time = if typeof time is 'number' then time else time.getTime()
      Math.floor int_time/1000/60/60/24
    progress: (open,close) ->
      if open is 0 and close is 0
        0
      else
        close/(close+open)*100

classes.Milestone = Backbone.Model.extend
  initialize: ->
    @set_duration()
    @set_progress()
    @parse_frontmatter()

  parse_frontmatter: ->
    if @get('description')?
      console.log @get('description').match(/^\-\-\-([\s\S]*)\-\-\-/m)

  set_progress: ->
    open = @get('open_issues')
    close = @get('closed_issues')
    if open is 0 and close is 0
      p = 0
    else
      p = close/(close+open)*100
    @set('progress',p)

  set_duration: ->
    created_int = new Date(@get('created_at')).getTime()
    if @get('due_on')?
      time_diff = new Date(@get('due_on')).getTime() - created_int
    else if @get('state') is 'closed'
      time_diff = new Date(@get('updated_at')).getTime() - created_int
    else
      time_diff = 10*24*60*60*1000
    @set('duration',time_diff)

classes.Milestones = Backbone.Collection.extend
  model: classes.Milestone
  comparator: 'created_at'

classes.MilestoneView = Backbone.View.extend
  initialize: ->
    @render().el

  left_position: ->
    classes.helpers.time_position(@model.get('created_at'),origin)

  render: ->
    # Go through each row, if it has children, see if the position of this view
    # would overlap with the last child of the row.
    for row in $("#wrapper .row")
      if $(row).children().length is 0
        $(row).append JST['milestone'](@model.toJSON())
        break
      else if $(row).children().last().position().left+$(row).children().last().width() < @left_position()
        $(row).append JST['milestone'](@model.toJSON())
        break
    @

classes.MilestonesView = Backbone.View.extend
  el: '#wrapper'
  initialize: ->
    _.each _.range(0,@collection.length / 3), -> $("#wrapper").append("<div class='row'/>")
    @render().el
  render: ->
    @collection.each (model) ->
      new classes.MilestoneView model:model
    setTimeout (->
      $('#wrapper').scrollLeft(classes.helpers.days(classes.helpers.today)*classes.helpers.day_width)

      $('.row').each ->
        objHeight = 0
        $(this).find('.milestone').each ->
          milestone_height = $(@).css('height').replace(/px/,'')
          console.log milestone_height
          if milestone_height > objHeight
            objHeight = milestone_height
        $(this).css('height',objHeight+'px')
    ), 100
    @

window.classes = classes

$ ->
  window.milestones = new classes.Milestones(data.milestones)
  milestones.sort()
  window.origin = new Date(milestones.first().get('created_at')).getTime()

  milestonesView = new classes.MilestonesView collection:milestones

  $('.milestone').click -> $(@).find('.description').toggle()