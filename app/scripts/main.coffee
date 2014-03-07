document.addEventListener 'WebComponentsReady', ->
  # Perform some behaviour
  return


ds = false # drag started
el1 = document.querySelector '.circleControl'
el2 = document.querySelector '.slider'
tp1 = 0 # circle top
tp2 = 0 # slider top
rto = 0 # ratio

hammertime = Hammer(el1).on 'dragup', (e) ->
  return unless ds

  top1 = Math.round tp1 + e.gesture.deltaY
  top2 = Math.round tp2 + (e.gesture.deltaY * rto)

  return if top1 < 0

  el1.style.top = "#{top1}px"
  el2.style.top = "#{top2}px"
  #console.log e.gesture.center.pageY+' vs '+e.gesture.deltaY
  return
# END dragup

Hammer(el1).on('dragstart', (e) ->
  ds  = true
  tp1 = el1.offsetTop
  tp2 = el2.offsetTop
  rto = tp2 / tp1

  el1.style.borderColor = 'red'
).on('dragend', (e) ->
  el1.style.top = "#{tp1}px"
  el2.style.top = "#{tp2}px"

  ds  = false;
  tp1 = 0
  tp2 = 0
  rto = 0
  el1.style.borderColor = '#aaa'
)


hammertime.options.prevent_default = yes