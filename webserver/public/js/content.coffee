get_color_from_token_class = (token_class) ->
  sum = 0
  for i in [0..token_class.length-1]
    sum += token_class.charCodeAt(i) * i
  h = sum % 31 * 11

  "hsl(#{ h }, 50%, 50%)"

create_token = (def) ->
  $('<span>').addClass('token').text(def.value).attr(title: def.token_class).css
      color: get_color_from_token_class(def.token_class)

highlight = (res) ->
  if res.is_valid
    $('#result').css
      border: '4px solid #88f'
  else
    $('#result').css
      border: '4px solid #f88'

  fragment = document.createDocumentFragment()

  $.each res.tokens, (i, data) ->
    node = create_token(data)
    fragment.appendChild(node[0])
  $('#result').empty().append(fragment)

  return
  highlight_histogram(res)

$ ->
  last = ''
  last_res = null

  setInterval ->
    body = $('#source-code').val()
    if last == body
      return
    last = body
    $.post '/'
      body: body
      mime_type: 'application/ruby'
      (res) ->
        return if body != $('#source-code').val()
        last_res = res
        highlight(res)
  , 1000
