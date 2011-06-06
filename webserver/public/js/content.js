var highlight;
highlight = function(tokens) {
  var fragment, max;
  fragment = document.createDocumentFragment();
  max = 0.0;
  $.each(tokens, function(i, pair) {
    var rate, token;
    token = pair[0], rate = pair[1];
    if (max < +rate) {
      return max = +rate;
    }
  });
  $.each(tokens, function(i, pair) {
    var color, level, node, rate, token;
    token = pair[0], rate = pair[1];
    level = rate / max * 100;
    if (isNaN(level) || level === Infinity) {
      level = 0;
    }
    color = "hsl(180, " + level + "%, 50%)";
    console.log(color);
    node = $('<span>').text(token).css({
      color: color
    });
    return fragment.appendChild(node[0]);
  });
  return $('#result').empty().append(fragment);
};
$(function() {
  return $('form').submit(function(event) {
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
});