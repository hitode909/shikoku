$ ->
  $('form').submit (event) ->
    body = $(this).find('textarea').val()
    event.preventDefault();
    $.post '/'
      body: body
      mime_type: 'application/ruby'
      (res) ->
        $('dl').empty()
        for token, rate of res
          $('dl').append $('<dt>').text token
          $('dl').append $('<dd>').text rate
    false
