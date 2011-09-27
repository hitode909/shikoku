fill_pattern = 'color'
fill_factor = 180.0

get_color = (level) ->
  level = 0.0 if level < 0.0
  level = 1.0 if level > 1.0
  level = Math.sin(level * Math.PI / 2)
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

highlight = (res) ->
  fragment = document.createDocumentFragment()
  total = res.total
  focus = res.focus

  max = 0.01

  $.each res.tokens, (i, data) ->
    node = create_token(data)
    console.log [node.text(), focus]
    if node.text() == focus
      node.css
       'font-weight': 'bold'
    fragment.appendChild(node[0])
  $('#result').empty().append(fragment)

preview_color = ->
  $('#color-sample').empty()
  for i in [0..500]
    $('#color-sample').append $('<span>').attr('data-rate-index', i).css
      display: 'inline-block'
      width: '1px'
      height: '30px'
      background: get_color(i / 500)

$ ->
  last = ''
  last_res = null

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

    $.post '/focus'
      body: $('form').find('textarea').val()
      focus: selected_token
      mime_type: 'application/ruby'
      (res) ->
        last_res = res
        highlight(res)

  $('#fill-factor').change ->
    fill_factor = $(this).val()
    preview_color()
    highlight(last_res) if last_res