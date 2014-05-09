classes =
  helpers:
    today: new Date()
    day_width: 50
    time_position: (time) ->
      @days(new Date(time).getTime() - @today.getTime())*@day_width
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
  initialize: (models) ->
    console.log models

window.classes = classes
window.milestones = new classes.Milestones(data.milestones)

$ ->
  creation_order = milestones.sortBy((m) -> m.get('created_at'))
  due_order = milestones.sortBy((m) -> m.get('due_on'))

  milestones.sort()

  milestones.each (milestone) ->
    $('#wrapper').append JST['milestone'](milestone.toJSON())
  $('.milestone').click -> $(@).find('.description').toggle()
