var create_token, get_color_from_token_class, highlight;
get_color_from_token_class = function(token_class) {
  var h, i, sum, _ref;
  sum = 0;
  for (i = 0, _ref = token_class.length - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
    sum += token_class.charCodeAt(i) * i;
  }
  h = sum % 31 * 11;
  return "hsl(" + h + ", 50%, 50%)";
};
create_token = function(def) {
  return $('<span>').addClass('token').text(def.value).attr({
    title: def.token_class
  }).css({
    color: get_color_from_token_class(def.token_class)
  });
};
highlight = function(res) {
  var fragment;
  if (res.is_valid) {
    $('#result').css({
      border: '4px solid #88f'
    });
  } else {
    $('#result').css({
      border: '4px solid #f88'
    });
  }
  fragment = document.createDocumentFragment();
  $.each(res.tokens, function(i, data) {
    var node;
    node = create_token(data);
    return fragment.appendChild(node[0]);
  });
  $('#result').empty().append(fragment);
  return;
  return highlight_histogram(res);
};
$(function() {
  var last, last_res;
  last = '';
  last_res = null;
  return setInterval(function() {
    var body;
    body = $('#source-code').val();
    if (last === body) {
      return;
    }
    last = body;
    return $.post('/', {
      body: body,
      mime_type: 'application/ruby'
    }, function(res) {
      if (body !== $('#source-code').val()) {
        return;
      }
      last_res = res;
      return highlight(res);
    });
  }, 1000);
});