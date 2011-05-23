$(function() {
  return $('form').submit(function(event) {
    var body;
    body = $(this).find('textarea').val();
    event.preventDefault();
    $.post('/', {
      body: body,
      mime_type: 'application/ruby'
    }, function(res) {
      var rate, token, _results;
      $('dl').empty();
      _results = [];
      for (token in res) {
        rate = res[token];
        $('dl').append($('<dt>').text(token));
        _results.push($('dl').append($('<dd>').text(rate)));
      }
      return _results;
    });
    return false;
  });
});