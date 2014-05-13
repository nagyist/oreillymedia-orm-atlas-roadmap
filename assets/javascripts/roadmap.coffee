atlas =
  helpers:
    today: new Date()
    day_width: 25
    time_position: (time,baseTime) ->
      diff = (new Date(time)).getTime() - baseTime
      @days(diff)*@day_width
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


atlas.Milestone = Backbone.Model.extend
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

  set_position: (baseTime) ->
    left = atlas.helpers.time_position(@get('created_at'),baseTime)
    width = atlas.helpers.days(@get('duration'))*atlas.helpers.day_width
    @set({left:left, width:width})

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

atlas.Milestones = Backbone.Collection.extend
  model: atlas.Milestone
  comparator: 'created_at'
  earliest: -> @min (m) -> (new Date(m.get('created_at'))).getTime()
  latest: -> @max (m) -> (new Date(m.get('created_at'))).getTime()
  origin: -> new Date(@earliest().get('created_at')).getTime()

atlas.MilestoneView = Backbone.View.extend
  className: -> "milestone " + @model.get('state')
  initialize: -> @model.set_position(@model.collection.origin())

  render: ->
    # Go through each row, if it has children, see if the position of this view
    # would overlap with the last child of the row.
    content = JST['milestone'](@model.toJSON())
    @$el.html content
    @$el.css({width:@model.get('width'),left:@model.get('left')})
    @

atlas.MilestonesView = Backbone.View.extend
  el: '#wrapper'
  initialize: ->
    _.each _.range(0,@collection.length / 3), -> $("#wrapper").append("<div class='row'/>")
    @render().el

  renderCalendar: ->
    # This _should_ work.
    last_date = new Date(@collection.latest().get('due_on') || @collection.latest().get('created_at'))
    last_timestamp = last_date.getTime()

    this_month = atlas.helpers.firstOfMonth(@collection.earliest().get('created_at'))

    # Render the calendar, setting the width of each month based on time
    # between start of this month and the end of the next. Append to the page
    # and increment the month
    while(this_month.getTime() < last_timestamp)
      next_month = atlas.helpers.nextMonth(this_month)

      left = atlas.helpers.time_position(this_month, @collection.origin())
      width = atlas.helpers.days(next_month.getTime() - this_month.getTime())*atlas.helpers.day_width

      $('.calendar').append JST['month']({month:this_month.getMonthName(), width:width, left:left})

      this_month = next_month

  render: ->
    t = @
    @collection.sort()
    @collection.each (model) ->
      view = new atlas.MilestoneView model:model
      for row in $("#wrapper .row")
        if $(row).children().length is 0
          $(row).append view.render().el
          break
        else if $(row).children().last().position().left+$(row).children().last().width() < model.get('left')
          $(row).append view.render().el
          break
    @renderCalendar()

    setTimeout (->
      $('#wrapper').scrollLeft(atlas.helpers.days(atlas.helpers.today)*atlas.helpers.day_width)
      atlas.helpers.setRowHeight()
    ), 100
    @

$ ->
  milestones = new atlas.Milestones(data.milestones)
  origin = new Date(milestones.first().get('created_at')).getTime()
  milestonesView = new atlas.MilestonesView collection:milestones
