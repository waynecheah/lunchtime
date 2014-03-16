document.addEventListener 'WebComponentsReady', ->
  # Perform some behaviour
  return

$('#mainmenu').mmenu
  classes: 'mm-light mm-zoom-menu'
  header: true
$('#groupMenu').mmenu
  classes: 'mm-zoom-panels'
  position: 'right'
  zposition: 'front'
  searchfield:
    add: true
    search: true
    placeholder: 'Search Group'

Hammer(document.querySelector '.icon-menu').on 'tap', ->
  $('#mainmenu').trigger 'open'
Hammer(document.querySelector '.icon-group').on 'tap', ->
  $('#groupMenu').trigger 'open'

window.onresize = ->
  console.log 'screen changed!'
  cir  = $('.circleControl').outerWidth()
  left = (screen.width - cir) / 2
  top  = (screen.height - cir) / 2
  $('.nextCircle').css 'left', "700px" if screen.height < 361
  $('.dimension').css 'width', screen.width+'px'
  $('.dimension').css 'height', screen.height+'px'
  $('.previousCircle, .nextCircle').css 'top', "#{top}px"
  $('.circleControl').css
    top: "#{top}px"
    left: "#{left}px"
  return



ds  = false # drag started
pds = false # page drag started
el  = $ '.circleControl'
eTx = $ '.actionName' # text show in center of the circle
elP = document.querySelector '.page'
ele = document.querySelector '.circleControl'
elL = document.querySelector '.previousCircle'
elR = document.querySelector '.nextCircle'
elU = document.querySelector '.sliderUp'
elD = document.querySelector '.sliderDown'
lfL = 0
lfC = 0
lfR = 0
tp  = 0 # circle top
tpU = 0 # slider up, css top
tpD = 0 # slider down, css top
rto = 0 # ratio
wdt = 0 # width circle width
acl = 0 # action taken when circle control almost reach left side
acr = 0 # action taken when circle control almost reach right side
pct = 0 # percentage
pst = no # position
hit = no
txt = null
cnt = 0

gotoNextRecord = ->
  number  = cnt + 2
  content = $('.nextCircle .circleContent').html()
  prevCon = if cnt is 0 then "What's for lunch" else "Choice #{cnt}"
  nextCon = if cnt is -2 then "What's for lunch" else "Choice #{number}"
  $('.circleControl .circleContent').html content
  $('.previousCircle .circleContent').html prevCon
  $('.nextCircle .circleContent').html nextCon
  cnt++
  return
# END gotoNextRecord

gotoPrevRecord = ->
  number  = cnt - 2
  content = $('.previousCircle .circleContent').html()
  prevCon = if cnt is 2 then "What's for lunch" else "Choice #{number}"
  nextCon = if cnt is 0 then "What's for lunch" else "Choice #{cnt}"
  $('.circleControl .circleContent').html content
  $('.previousCircle .circleContent').html prevCon
  $('.nextCircle .circleContent').html nextCon
  cnt--
  return
# END gotoPrevRecord

hammerPage = Hammer(elP).on 'dragleft', (e) -> # next targets
  return unless pds is yes

  left1 = lfC.left + e.gesture.deltaX
  left2 = lfR.left + e.gesture.deltaX

  pst = if left1 < acl then 'left' else no

  ele.style.left = "#{left1}px"
  $('.nextCircle').css 'left', "#{left2}px"
# END drag

hammerPage = Hammer(elP).on 'dragright', (e) -> # back previous history
  return unless pds is yes

  left1 = lfC.left + e.gesture.deltaX
  left2 = lfL.left + e.gesture.deltaX

  pst = if left1 > acr then 'right' else no

  $('.circleControl').css 'left', "#{left1}px"
  $('.previousCircle').css 'left', "#{left2}px"
# END drag

Hammer(elP).on('dragstart', ->
  pds = yes
  wdt = $('.circleControl').width()
  lfL = $('.previousCircle').position()
  lfC = $('.circleControl').position()
  lfR = $('.nextCircle').position()
  acl = (wdt / 3) * 2
  acl = acl - (acl * 2)
  acr = $('.page').width() - ((wdt / 3) * 1)
  pst = no

  $('.previousCircle, .circleControl, .nextCircle').removeClass 'animateLeft'
).on('dragend', ->
  return unless pds is yes

  fnReset = (position) ->
    $('.previousCircle').css 'left', "#{lfL.left}px"
    $('.circleControl').css 'left', "#{lfC.left}px"
    $('.nextCircle').css 'left', "#{lfR.left}px"

    gotoNextRecord() if position is 'left'
    gotoPrevRecord() if position is 'right'

    lfL = 0
    lfC = 0
    lfR = 0
    return
  # END fnReset

  $('.previousCircle, .circleControl, .nextCircle').addClass 'animateLeft'

  if pst is 'left' # goto next
    $('.circleControl').css 'left', "#{lfL.left}px"
    $('.nextCircle').css 'left', "#{lfC.left}px"
  else if pst is 'right' # back to previous
    $('.circleControl').css 'left', "#{lfR.left}px"
    $('.previousCircle').css 'left', "#{lfC.left}px"
  else
    fnReset null

  if pst
    setTimeout ->
      el.removeClass 'animateTop chosen getDown'
      eTx.css 'color', "rgba(0, 0, 0, 0)"
      $('.undo').hide()

      $('.previousCircle, .circleControl, .nextCircle').removeClass 'animateLeft'
      fnReset pst
      return
    , 100

  pds = no;
  wdt = 0

  el.removeClass 'dragging'
)



hammertime = Hammer(ele).on 'dragup', (e) -> # choose
  return unless ds

  top1 = Math.round tp + e.gesture.deltaY
  top2 = Math.round tpU + e.gesture.deltaY
  #top2 = Math.round tpU + (e.gesture.deltaY * rto)
  opac = Math.round((0 - e.gesture.deltaY) * pct) / 100

  eTx.css 'color', "rgba(0, 0, 0, #{opac})"
  unless txt
    eTx.html 'Take This One'
    txt = 'up'

  if top2 < 1 # animate drop back effect to original position
    hit = yes
    return
  else
    hit = no

  ele.style.top = "#{top1}px"
  elU.style.top = "#{top2}px"

  return
# END dragup

hammerdown = Hammer(ele).on 'dragdown', (e) -> # make disapper
  return unless ds

  top1 = Math.round tp + e.gesture.deltaY
  top2 = Math.round tpD + e.gesture.deltaY
  opac = Math.round(e.gesture.deltaY * pct) / 100

  eTx.css 'color', "rgba(0, 0, 0, #{opac})"
  unless txt
    eTx.html 'Skip This One'
    txt = 'down'

  if top2 > 0 # animate pull back effect to original position
    hit = yes
    return
  else
    hit = no

  ele.style.top = "#{top1}px"
  elD.style.top = "#{top2}px"

  return
# END dragdown


Hammer(ele).on('dragstart', (e) ->
  ds  = true
  tp  = ele.offsetTop
  tpU = elU.offsetTop
  tpD = elD.offsetTop
  rto = tpU / tp
  pct = 100 / tpU
  hit = no
  txt = null

  #console.log 'start '+e.gesture.center.pageY

  el.addClass('dragging').removeClass 'animateTop chosen getDown'
  $('.circleContent').hide() if e.gesture.direction is 'up' or e.gesture.direction is 'down'
  $('.undo').hide()
).on('dragend', ->
  console.log ds
  return unless ds is true

  if hit is yes
    if txt is 'up' then el.addClass 'chosen' else el.addClass 'getDown'
    $('.undo').show()
  else
    $('.circleContent').show()
    eTx.css 'color', 'rgba(0, 0, 0, 0)'

  el.addClass 'animateTop'

  ele.style.top = "#{tp}px"
  elU.style.top = "#{tpU}px"
  elD.style.top = "#{tpD}px"

  ds  = false;
  tp  = 0
  tpU = 0
  tpD = 0
  rto = 0
  pct = 0

  el.removeClass 'dragging'
)

undoEl = document.querySelector '.undo'
Hammer(undoEl).on 'tap', ->
  el.removeClass 'animateTop chosen getDown'
  $('.undo').hide()


hammertime.options.prevent_default = yes
hammerdown.options.prevent_default = yes