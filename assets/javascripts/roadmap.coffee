window.milestones = new Backbone.Collection(data.milestones)

window.helpers =
  progress: (open,close) ->
    if open is 0 and close is 0
      0
    else
      close/(close+open)*100

$ ->

  creation_order = milestones.sortBy((m) -> m.get('created_at'))
  due_order = milestones.sortBy((m) -> m.get('due_on'))
  console.log _.first(creation_order).get("created_at")
  console.log due_order

  milestones.each (milestone) ->
    $('#wrapper').append JST['milestone'](milestone.toJSON())

  $('.milestone').click ->
    $(@).find('.description').toggle()
