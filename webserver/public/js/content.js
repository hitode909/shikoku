var get_color, highlight;
get_color = function(level) {
  var h, l;
  h = 300 - level * 300.0;
  l = level < 0.1 ? level / 0.1 * 50 : 50;
  return "hsl(" + h + ", 100%, " + l + "%)";
};
highlight = function(res) {
  var fragment, max, total;
  fragment = document.createDocumentFragment();
  total = res.total;
  max = 0;
  $.each(res.tokens, function(i, data) {
    var count, rate, value;
    value = data.value, count = data.count, rate = data.rate;
    if (max < count) {
      return max = count;
    }
  });
  $.each(res.tokens, function(i, data) {
    var color, count, level, node, rate, title, value;
    value = data.value, count = data.count, rate = data.rate;
    level = Math.log(count) / Math.log(max);
    if (isNaN(level) || level === Infinity) {
      level = 0;
    }
    color = get_color(level);
    title = value.match(/\S/) ? count : '';
    node = $('<span>').addClass('token').text(value).attr('title', title).css({
      color: color
    });
    return fragment.appendChild(node[0]);
  });
  return $('#result').empty().append(fragment);
};
$(function() {
  var i, _results;
  $('form').submit(function(event) {
    var body;
    body = $(this).find('textarea').val();
    event.preventDefault();
    $.post('/', {
      body: body,
      mime_type: 'application/ruby'
    }, function(res) {
      return highlight(res);
    });
    return false;
  });
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
});