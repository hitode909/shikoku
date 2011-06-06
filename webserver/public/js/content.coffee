get_color = (level) ->
  h =  300 - level * 300.0
  l = if level < 0.1 then level / 0.1 * 50 else 50
  "hsl(#{ h }, 100%, #{ l }%)"

highlight = (res) ->
  fragment = document.createDocumentFragment()
  total = res.total

  max = 0
  $.each res.tokens, (i, data) ->
    {value, count, rate} = data
    max = count if max < count

  $.each res.tokens, (i, data) ->
    {value, count, rate} = data

    level = Math.log(count) / Math.log(max)
    level = 0 if isNaN(level) or level == Infinity
    color = get_color(level)
    title = if value.match(/\S/) then count else ''
    node = $('<span>').addClass('token').text(value).attr('title', title).css
      color: color
    fragment.appendChild(node[0])
  $('#result').empty().append(fragment)

$ ->
  $('form').submit (event) ->
    body = $(this).find('textarea').val()
    event.preventDefault();
    $.post '/'
      body: body
      mime_type: 'application/ruby'
      (res) ->
        highlight(res)
    false

  for i in [0..600]
    $('#color-sample').append $('<span>').css(display: 'inline-block', width: '1px', height: '30px', background: get_color(i / 600))
