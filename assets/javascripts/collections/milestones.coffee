class map.Milestones extends Backbone.Collection
  
  model: map.Milestone
  
  comparator: 'created_at'
  
  earliest: -> @min (m) -> (new Date(m.get('created_at'))).getTime()
  latest: -> @max (m) -> (new Date(m.get('created_at'))).getTime()
  origin: -> new Date(@earliest().get('created_at')).getTime()