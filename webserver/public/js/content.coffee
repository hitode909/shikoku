highlight = (tokens) ->
  fragment = document.createDocumentFragment()
  max = 0.0

  $.each tokens, (i, pair) ->
    [token, rate] = pair
    max = +rate if max < +rate

  $.each tokens, (i, pair) ->
    [token, rate] = pair
    level = rate / max * 100
    level = 0 if isNaN(level) or level == Infinity
    color = "hsl(180, #{ level }%, 50%)"
    console.log color
    node = $('<span>').text(token).css
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
