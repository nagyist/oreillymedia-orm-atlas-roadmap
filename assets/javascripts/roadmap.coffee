window.milestones = new Backbone.Collection(data.milestones)
milestones.comparator = 'created_at'

window.helpers =
  day_width: 50
  set_width: (model) ->
    if model.duration?
      @days(model.duration)*@day_width
    else
      10*@day_width
  days: (time) ->
    Math.ceil time.getTime()/1000/60/60/24
  progress: (open,close) ->
    if open is 0 and close is 0
      0
    else
      close/(close+open)*100

$ ->
  creation_order = milestones.sortBy((m) -> m.get('created_at'))
  due_order = milestones.sortBy((m) -> m.get('due_on'))
  milestones.sort()
  milestones.each (milestone) ->
    # console.log milestone.get('created_at'), milestone.get('due_on')

    console.log milestone.get('title')
    if milestone.get('due_on')?
      duration =  new Date(milestone.get('due_on')).getTime() - new Date(milestone.get('created_at')).getTime()
      milestone.set('duration', new Date(duration))
    else if milestone.get('state') is "closed"
      duration = new Date(milestone.get('updated_at')).getTime() - new Date(milestone.get('created_at')).getTime()
      milestone.set('duration', new Date(duration))

    $('#wrapper').append JST['milestone'](milestone.toJSON())

  $('.milestone').click ->
    $(@).find('.description').toggle()
