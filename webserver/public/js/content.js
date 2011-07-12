var fill_pattern, get_color, highlight, last_res, preview_color;
fill_pattern = 'color';
last_res = null;
get_color = function(level) {
  var h, l, rlevel;
  if (level < 0.0) {
    level = 0.0;
  }
  if (level > 1.0) {
    level = 1.0;
  }
  if (fill_pattern === 'color') {
    rlevel = 1.0 - level;
    h = level > 0.0 ? 90 + rlevel * 180.0 : 0.0;
    l = rlevel * 50;
    return "hsl(" + h + ", 100%, " + l + "%)";
  } else {
    return "hsl(0, 0%, " + (level * 90) + "%)";
  }
};
highlight = function(res) {
  var fragment, max, total;
  fragment = document.createDocumentFragment();
  total = res.total;
  max = 0.01;
  $.each(res.tokens, function(i, data) {
    var color, count, level, node, rate, title, value;
    value = data.value, count = data.count, rate = data.rate;
    level = rate * 10;
    level = Math.log(rate + 1) / Math.log(max + 1);
    level = rate / max;
    if (isNaN(level) || level === Infinity || level === -Infinity) {
      level = 0;
    }
    color = get_color(level);
    title = value.match(/\S/) ? count : '';
    node = $('<span>').addClass('token').text(value).attr('title', "" + title + " (" + (rate * 100) + ")").css({
      color: color
    });
    return fragment.appendChild(node[0]);
  });
  return $('#result').empty().append(fragment);
};
preview_color = function() {
  var i, _results;
  $('#color-sample').empty();
  _results = [];
  for (i = 0; i <= 600; i++) {
    _results.push($('#color-sample').append($('<span>').css({
      display: 'inline-block',
      width: '1px',
      height: '30px',
      background: get_color(i / 600)
    })));
  }
  return _results;
};
$(function() {
  var last;
  last = '';
  setInterval(function() {
    var body;
    body = $('form').find('textarea').val();
    if (last === body) {
      return;
    }
    last = body;
    $.post('/', {
      body: body,
      mime_type: 'application/ruby'
    }, function(res) {
      last_res = res;
      return highlight(res);
    });
    return false;
  }, 1000);
  $('input[name="fill-type"]').change(function() {
    fill_pattern = $(this).val();
    preview_color();
    return highlight(last_res);
  });
  return preview_color();
});