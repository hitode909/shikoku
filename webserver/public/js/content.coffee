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
    l = (1-level*level) * 50
    "hsl(#{ h }, 100%, #{ l }%)"
  else
    "hsl(0, 0%, #{ level * 90 }%)"

create_token = (def) ->
  $('<span>').addClass('token').text(def.value).attr('title', "#{ def.count } (#{ def.rate * 100 })", "data-rate", def.rate).css
      color: get_color(def.rate)

highlight = (res) ->
  fragment = document.createDocumentFragment()
  total = res.total

  max = 0.01
  # $.each res.tokens, (i, data) ->
  #   {value, count, rate} = data
  #   max = count if max < count

  $.each res.tokens, (i, data) ->
    # {value, count, rate} = data

    # level = rate * 10
    # level = Math.log(rate+1) / Math.log(max+1)
    # level = rate / max
    # level = rate
    # level = 0 if isNaN(level) or level == Infinity or level == -Infinity
    # color = get_color(rate)
    node = create_token(data)
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
    if selected_token && $(event.target).parents('#completions-container').length > 0
      selected_token.replaceWith($(this))
      selected_token = null
      completions_container.hide()
      return true

    selected_token = $(this)
    completions_container.empty().show()
    completions_container.css
      left: $(this).position().left + 20
      top: $(this).position().top + 20
    loading = $('<div>').text('...').css('class', 'loading')
    completions_container.append($('<strong>').append($(this).clone(true))).append($('<hr>')).append(loading)
    $.get '/suggest', {token: $(this).text() }, (res) ->
      loading.remove()
      for item in res
        completions_container.append $('<div>').append(create_token(item))

  $('body').click (event) ->
    unless $(event.target).parents('#completions-container').length
      completions_container.hide()
      selected_token = null
