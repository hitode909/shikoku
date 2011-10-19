fill_pattern = 'color'
fill_factor = 180.0
color_sample_length = 500

throttle = (fn, delay) ->
  timer = null
  ->
    return if timer
    context = this
    args = arguments
    timer = setTimeout ->
      timer = null
      fn.apply context, args
    ,delay


get_color = (level) ->
  level = 0.0 if level < 0.0
  level = 1.0 if level > 1.0
  # level = Math.sin(level * Math.PI / 2)
  # level = Math.log(level + 1.0) / Math.log(2.0)
  if fill_pattern == 'color'
    rlevel = 1.0 - level
    # fill_factor * 0.5 のところ いい感じにしたい
    h =  if level > 0.0 then fill_factor * 0.5 + rlevel * fill_factor else 0.0
    l = (1.0 - Math.pow(level, 5)) * 50
    "hsl(#{ h }, 100%, #{ l }%)"
  else
    "hsl(0, 0%, #{ level * 90 }%)"

create_token = (def) ->
  $('<span>').addClass('token').text(def.value).attr('title', "#{ def.count } (#{ def.rate * 100 })", "data-rate", def.rate).css
      color: get_color(def.rate)

highlight_histogram = (res) ->
  fragment = document.createDocumentFragment()
  summary = {}
  $.each res.tokens, (i, data) ->
    return unless data.value.match(/\S/)
    index = Math.floor(data.rate * color_sample_length)
    summary[index] ?= 0
    summary[index] += 1 / res.tokens.length

  list = []
  for i in [0..color_sample_length]
    list[i] = summary[i] || 0

  preview_color_by_summary(round_list(list, 200))

round_list = (list, range) ->
  res = []
  for i in [0..(list.length-1)]
    v = 0
    for j in [Math.floor(i - range*0.5)..Math.floor(i + range*0.5)]
      if 0 <= j && j < list.length && list[j] > 0
        v += list[j] * Math.pow(0.9,  Math.abs(i - j))
    res[i] = v

  res

highlight = (res) ->
  fragment = document.createDocumentFragment()
  total = res.total
  focus = res.focus

  $.each res.tokens, (i, data) ->
    node = create_token(data)
    if node.text() == focus
      node.css
       'font-weight': 'bold'
    fragment.appendChild(node[0])
  $('#result').empty().append(fragment)

  highlight_histogram(res)

preview_color = ->
  $('#color-sample').empty()
  for i in [0..color_sample_length]
    $('#color-sample').append $('<span>').attr('data-rate-index', i).css
      background: get_color(i / color_sample_length)

preview_color_by_summary = (summary)->
  $('#color-sample').empty()
  for i in [0..color_sample_length]
    height = 200 * (Math.log(summary[i] + 1) / Math.log(2.0))
    $('#color-sample').append $('<span>').attr('data-rate-index', i).css
      height: "#{height}px"
      background: get_color(i / color_sample_length + 0.0001)

$ ->
  last = ''
  last_res = null

  fill_factor = $('#fill-factor').val()

  setInterval ->
    body = $('form').find('textarea').val()
    if last == body
      return
    last = body
    $.post '/'
      body: body
      mime_type: 'application/ruby'
      (res) ->
        last_res = res
        highlight(res)
  , 1000

  $('input[name="fill-type"]').change ->
    fill_pattern = $(this).val()
    preview_color()
    highlight(last_res)

  preview_color()

  selected_token = null

  completions_container = $('#completions-container')

  $('.token').live 'click', (event) ->

    selected_token = $(this).text()

    $('#result').css
      background: '#ddd'
    $.post '/focus'
      body: $('form').find('textarea').val()
      focus: selected_token
      mime_type: 'application/ruby'
      (res) ->
        $('#result').css
          background: ''
        last_res = res
        highlight(res)

  $('#fill-factor').change throttle((event) ->
    fill_factor = $(this).val()
    preview_color()
    highlight(last_res) if last_res
  , 100)