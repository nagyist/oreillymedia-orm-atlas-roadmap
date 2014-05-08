window.milestones = new Backbone.Collection(data.milestones)

window.helpers =
  day_width: 50
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
  # console.log _.first(creation_order).get("created_at")
  # console.log due_order

  milestones.each (milestone) ->
    # console.log milestone.get('created_at'), milestone.get('due_on')

    if milestone.get('due_on')?
      duration =  new Date(milestone.get('due_on')).getTime() - new Date(milestone.get('created_at')).getTime()
      milestone.set('duration', new Date(duration))
      console.log helpers.days(milestone.get('duration')), milestone.get('title')

    $('#wrapper').append JST['milestone'](milestone.toJSON())

  $('.milestone').click ->
    $(@).find('.description').toggle()
