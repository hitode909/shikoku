var create_token, get_color_from_token_class, get_color_from_token_class_and_rate, highlight;
get_color_from_token_class = function(token_class) {
  var h, i, sum, _ref;
  sum = 0;
  for (i = 0, _ref = token_class.length - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
    sum += token_class.charCodeAt(i) * i;
  }
  h = sum % 31 * 11;
  return "hsl(" + h + ", 50%, 50%)";
};
get_color_from_token_class_and_rate = function(token_class, rate) {
  var h, i, l, s, sum, _ref;
  sum = 0;
  for (i = 0, _ref = token_class.length - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
    sum += token_class.charCodeAt(i) * i;
  }
  h = sum % 31 * 11;
  s = 50;
  l = (0.5 - rate * rate) * 100;
  if (rate === 0.0) {
    l = 60;
  }
  if (l < 0) {
    l = 0;
  }
  return "hsl(" + h + ", " + s + "%, " + l + "%)";
};
create_token = function(def) {
  return $('<span>').addClass('token').text(def.value).attr({
    title: "" + def.token_class + " " + def.count + " " + (Math.floor(def.rate * 100)) + "%"
  }).css({
    color: def.color
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
  var last_body, last_mime_type, last_res;
  last_body = '';
  last_mime_type = '';
  last_res = null;
  return setInterval(function() {
    var body, mime_type;
    body = $('#source-code').val();
    mime_type = $('#mime-type').val();
    if (last_body === body && last_mime_type === mime_type) {
      return;
    }
    last_body = body;
    last_mime_type = mime_type;
    return $.post('/', {
      body: body,
      mime_type: mime_type
    }, function(res) {
      if (body !== $('#source-code').val()) {
        return;
      }
      last_res = res;
      return highlight(res);
    });
  }, 1000);
});