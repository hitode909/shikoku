fill_pattern = 'color'
last_res = null

get_color = (level) ->
  level = 0.0 if level < 0.0
  level = 1.0 if level > 1.0
  if fill_pattern == 'color'
    rlevel = 1.0 - level
    h =  if level > 0.0 then 90 + rlevel * 180.0 else 0.0
    # factor = 0.9
    # l = if level < 0.1 then 50 else 0
    # l = if rlevel < factor then rlevel / factor * 50 else 50
    l = rlevel * 50
    "hsl(#{ h }, 100%, #{ l }%)"
  else
    "hsl(0, 0%, #{ level * 90 }%)"

highlight = (res) ->
  fragment = document.createDocumentFragment()
  total = res.total

  max = 0.01
  # $.each res.tokens, (i, data) ->
  #   {value, count, rate} = data
  #   max = count if max < count

  $.each res.tokens, (i, data) ->
    {value, count, rate} = data

    level = rate * 10
    level = Math.log(rate+1) / Math.log(max+1)
    level = rate / max
    level = 0 if isNaN(level) or level == Infinity or level == -Infinity
    color = get_color(level)
    title = if value.match(/\S/) then count else ''
    node = $('<span>').addClass('token').text(value).attr('title', "#{ title } (#{ rate * 100 })").css
      color: color
    fragment.appendChild(node[0])
  $('#result').empty().append(fragment)

preview_color = ->
  $('#color-sample').empty()
  for i in [0..600]
    $('#color-sample').append $('<span>').css
      display: 'inline-block'
      width: '1px'
      height: '30px'
      background: get_color(i / 600)


$ ->
  last = ''
  setInterval ->
    body = $('form').find('textarea').val()
    if last == body
      return
    last = body
    # event.preventDefault();
    $.post '/'
      body: body
      mime_type: 'application/ruby'
      (res) ->
        last_res = res
        highlight(res)
    false
  , 1000

  $('input[name="fill-type"]').change ->
    fill_pattern = $(this).val()
    preview_color()
    highlight(last_res)

  preview_color()