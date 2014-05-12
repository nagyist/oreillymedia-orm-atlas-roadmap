classes =
  helpers:
    today: new Date()
    day_width: 25
    time_position: (time,origin) ->
      diff = (new Date(time)).getTime() - origin
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
    setRowHeight: ->
      $('.row').each ->
        objHeight = 0
        $(this).find('.milestone').each ->
          milestone_height = $(@).css('height').replace(/px/,'')
          if milestone_height > objHeight
            objHeight = milestone_height
        $(this).css('height',objHeight+'px')
    firstOfMonth: (date) ->
      d = new Date(date)
      d.setHours(0)
      d.setMinutes(0)
      d.setSeconds(0)
      d.setMilliseconds(0)
      d
    nextMonth: (date) ->
      d = new Date(date)
      d.moveToMonth(d.getMonth()+1)


classes.Milestone = Backbone.Model.extend
  initialize: ->
    @parse_frontmatter()


  parse_frontmatter: ->
    # see if there is frontmatter
    if @get('description')? and match = @get('description').match(/^\-\-\-([\s\S]*)\-\-\-/m)
      frontMatter = match[1]
      frontMatter = YAML.parse(frontMatter)
      if _.has(frontMatter, 'start')
        d = new Date(frontMatter.start)
        @set('created_at', "#{d}")
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
  earliest: -> @min (m) -> (new Date(m.get('created_at'))).getTime()
  latest: -> @max (m) -> (new Date(m.get('created_at'))).getTime()

classes.MilestoneView = Backbone.View.extend
  initialize: ->
    @render().el

  left_position: ->
    classes.helpers.time_position(@model.get('created_at'),origin)

  render: ->
    # Go through each row, if it has children, see if the position of this view
    # would overlap with the last child of the row.
    content = JST['milestone'](@model.toJSON())
    for row in $("#wrapper .row")
      if $(row).children().length is 0
        $(row).append content
        break
      else if $(row).children().last().position().left+$(row).children().last().width() < @left_position()
        $(row).append content
        break

    @

classes.MilestonesView = Backbone.View.extend
  el: '#wrapper'
  initialize: ->
    _.each _.range(0,@collection.length / 3), -> $("#wrapper").append("<div class='row'/>")
    @render().el

  render: ->
    @collection.sort()
    @collection.each (model) ->
      new classes.MilestoneView model:model

    # This _should_ work.
    last_date = new Date(@collection.latest().get('due_on') || @collection.latest().get('created_at'))

    earliest_month = classes.helpers.firstOfMonth(new Date(@collection.earliest().get('created_at')))

    this_month = earliest_month

    # Render the calendar
    while(this_month.getTime() < last_date.getTime())
      next_month = classes.helpers.nextMonth(this_month)

      left = classes.helpers.time_position(this_month, origin)
      # the width should be the length of days between these two months
      width = classes.helpers.days(next_month.getTime() - this_month.getTime())*classes.helpers.day_width

      # Render the month to the page
      $('.calendar').append JST['month']({month:this_month.getMonthName(), width:width, left:left})
      # advance the month for the loop
      this_month = next_month


    setTimeout (->
      $('#wrapper').scrollLeft(classes.helpers.days(classes.helpers.today)*classes.helpers.day_width)

      classes.helpers.setRowHeight()
    ), 100
    @

window.classes = classes

$ ->
  window.milestones = new classes.Milestones(data.milestones)
  window.origin = new Date(milestones.first().get('created_at')).getTime()
  milestonesView = new classes.MilestonesView collection:milestones
