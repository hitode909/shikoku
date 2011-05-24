$(function() {
  return $('form').submit(function(event) {
    var body;
    body = $(this).find('textarea').val();
    event.preventDefault();
    $.post('/', {
      body: body,
      mime_type: 'application/ruby'
    }, function(res) {
      var pair, rate, token, _i, _len, _results;
      $('dl').empty();
      _results = [];
      for (_i = 0, _len = res.length; _i < _len; _i++) {
        pair = res[_i];
        token = pair[0], rate = pair[1];
        $('dl').append($('<dt>').text("'" + token + "'"));
        _results.push($('dl').append($('<dd>').text(rate)));
      }
      return _results;
    });
    return false;
  });
});