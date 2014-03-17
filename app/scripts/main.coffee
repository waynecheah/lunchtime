document.addEventListener 'WebComponentsReady', ->
  # Perform some behaviour
  return

$('#mainmenu').mmenu
  classes: 'mm-light'
  header: true
$('#groupMenu').mmenu
  position: 'right'
  zposition: 'front'
  searchfield:
    add: true
    search: true
    placeholder: 'Search Group'

$.each $('.pt-page .ln'), (i, el) ->
  Hammer(el).on 'tap', -> # Animate each page change
    pages = $(@).attr('data-page').split '-'
    tabNo = $(@).attr('data-tab')

    if pages[0] and pages[1]
      reverse = if pages[2] is 'r' then yes else no
      tabNo   = if pages[3] then pages[3] else null
      changePage pages[0], pages[1], reverse, tabNo
    return
  return

Hammer(document.querySelector '.icon-menu').on 'tap', ->
  setTimeout ->
    $('#mainmenu').trigger 'open'
  , 10
Hammer(document.querySelector '.icon-group').on 'tap', ->
  setTimeout ->
    $('#groupMenu').trigger 'open'
  , 10
Hammer(document.querySelector '.icon-menu2').on 'tap', ->
  setTimeout ->
    $('#mainmenu').trigger 'open'
  , 10
Hammer(document.querySelector '.icon-group2').on 'tap', ->
  setTimeout ->
    $('#groupMenu').trigger 'open'
  , 10

window.onresize = ->
  console.log 'screen changed!'
  cir  = $('.circleControl').outerWidth()
  left = (screen.width - cir) / 2
  top  = (screen.height - cir - 120) / 2
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
fsp = no # fast swap position
hit = no
txt = null
cnt = 0
transition =
  fxOut: 'pt-page-moveToLeft'
  fxIn: 'pt-page-moveFromRight'
  fxRevOut: 'pt-page-moveToRight'
  fxRevIn: 'pt-page-moveFromLeft'

changePage = (from, to, reverse, tabNo, ts=transition) ->
  fPage = "div.pt-page-#{from}"
  tPage = "div.pt-page-#{to}"
  fxIn  = if reverse then ts.fxRevIn else ts.fxIn
  fxOut = if reverse then ts.fxRevOut else ts.fxOut

  sHeight = $(window).height() # get screen height
  $("#{tPage} div.body")
  .css 'min-height', "#{sHeight}px" # make page body to have same height as the screen

  fixedHeader = $('#fixHeader div.header')
  if fixedHeader.length > 0 # if there is any content in current fixed header
    hdPage = fixedHeader.attr 'data-page' # first to find where is it original page came from
    $("div.pt-page-#{hdPage}")
    .prepend fixedHeader # then put the header back tp the page

  $(window).trigger 'changePage', [from, to]
  $(fPage).addClass "pt-page-current #{fxOut}"
  $(tPage).addClass "pt-page-current #{fxIn} pt-page-ontop"

  setTimeout () -> # when transition is done
    $("#{tPage} div.body").css 'min-height', 200

    $(fPage).removeClass "pt-page-current #{fxOut}"
    $(tPage).removeClass "#{fxIn} pt-page-ontop"

    header = $("#{tPage} div.header")
    if header.length > 0 # if there is any content in destination header
      $('#fixHeader').html(header).show() # first to migrate the header content from original page to fixed header
      $('#fixHeader div.header').attr 'data-page', to # and don't forget to tell where this header original came from

    return
  , 400

  return
# END changePage

gotoNextRecord = ->
  number  = cnt + 2
  content = $('.nextCircle .circleContent').html()
  prevCon = if cnt is 0 then "What's for lunch" else "Choice #{cnt}"
  nextCon = if cnt is -2 then "What's for lunch" else "Choice #{number}"
  $('.circleControl .circleContent').show().html content
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
  $('.circleControl .circleContent').show().html content
  $('.previousCircle .circleContent').html prevCon
  $('.nextCircle .circleContent').html nextCon
  cnt--
  return
# END gotoPrevRecord

hammerLeft = Hammer(elP).on 'dragleft', (e) -> # next targets
  return unless pds is yes

  left1 = lfC.left + e.gesture.deltaX
  left2 = lfR.left + e.gesture.deltaX

  pst = if left1 < acl then 'left' else no

  ele.style.left = "#{left1}px"
  $('.nextCircle').css 'left', "#{left2}px"
# END drag

hammerRight = Hammer(elP).on 'dragright', (e) -> # back previous history
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
  return
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

  if pst is 'left' or fsp is 'left' # goto next
    $('.circleControl').css 'left', "#{lfL.left}px"
    $('.nextCircle').css 'left', "#{lfC.left}px"
  else if pst is 'right' or fsp is 'right' # back to previous
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
  return
)

hammerLeft.options.prevent_default  = yes
hammerRight.options.prevent_default = yes



startT = 0
pLeft  = 0
pCtrl  = 0
pRight = 0
elCont = document.querySelector '.page'
hmTime = Hammer(elCont).on 'touch', ->
  fsp    = no
  startT = performance.now()
  pLeft  = $('.previousCircle').position()
  pCtrl  = $('.circleControl').position()
  pRight = $('.nextCircle').position()
  $('.previousCircle, .circleControl, .nextCircle').removeClass 'animateLeft'
  return
hmTime.options.prevent_default = on

hmTime = Hammer(elCont).on 'release', (event) ->
  et = performance.now()
  dt = event.gesture.distance
  dr = event.gesture.direction
  td = et - startT # touch duration

  if td > 80 and td < 300 and dt > 100
    fnReset = (position) ->
      gotoNextRecord() if position is 'left'
      gotoPrevRecord() if position is 'right'

      $('.previousCircle').css 'left', "#{pLeft.left}px"
      $('.circleControl').css 'left', "#{pCtrl.left}px"
      $('.nextCircle').css 'left', "#{pRight.left}px"

      pLeft  = 0
      pCtrl  = 0
      pRight = 0
      return
    # END fnReset

    $('.previousCircle, .circleControl, .nextCircle').addClass 'animateLeft'

    if dr is 'left' # goto next
      $('.circleControl').css 'left', "#{pLeft.left}px"
      $('.nextCircle').css 'left', "#{pCtrl.left}px"
    else if dr is 'right' # back to previous
      $('.circleControl').css 'left', "#{pRight.left}px"
      $('.previousCircle').css 'left', "#{pCtrl.left}px"

    setTimeout ->
      el.removeClass 'animateTop chosen getDown'
      eTx.css 'color', "rgba(0, 0, 0, 0)"
      $('.undo').hide()

      $('.previousCircle, .circleControl, .nextCircle').removeClass 'animateLeft'
      fnReset dr
      return
    , 100

  return




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
  $('.circleControl .circleContent').hide() if e.gesture.direction is 'up' or e.gesture.direction is 'down'
  $('.undo').hide()
).on('dragend', ->
  return unless ds is true

  if hit is yes
    if txt is 'up' then el.addClass 'chosen' else el.addClass 'getDown'
    $('.undo').show()
  else
    $('.circleControl .circleContent').show()
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