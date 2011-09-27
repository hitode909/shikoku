var create_token, fill_factor, fill_pattern, get_color, highlight, preview_color, throttle;
fill_pattern = 'color';
fill_factor = 180.0;
throttle = function(fn, delay) {
  var timer;
  timer = null;
  return function() {
    var args, context;
    if (timer) {
      return;
    }
    context = this;
    args = arguments;
    return timer = setTimeout(function() {
      timer = null;
      return fn.apply(context, args);
    }, delay);
  };
};
get_color = function(level) {
  var h, l, rlevel;
  if (level < 0.0) {
    level = 0.0;
  }
  if (level > 1.0) {
    level = 1.0;
  }
  level = Math.sin(level * Math.PI / 2);
  if (fill_pattern === 'color') {
    rlevel = 1.0 - level;
    h = level > 0.0 ? fill_factor * 0.5 + rlevel * fill_factor : 0.0;
    l = (1.0 - Math.pow(level, 5)) * 50;
    return "hsl(" + h + ", 100%, " + l + "%)";
  } else {
    return "hsl(0, 0%, " + (level * 90) + "%)";
  }
};
create_token = function(def) {
  return $('<span>').addClass('token').text(def.value).attr('title', "" + def.count + " (" + (def.rate * 100) + ")", "data-rate", def.rate).css({
    color: get_color(def.rate)
  });
};
highlight = function(res) {
  var focus, fragment, max, total;
  fragment = document.createDocumentFragment();
  total = res.total;
  focus = res.focus;
  max = 0.01;
  $.each(res.tokens, function(i, data) {
    var node;
    node = create_token(data);
    if (node.text() === focus) {
      node.css({
        'font-weight': 'bold'
      });
    }
    return fragment.appendChild(node[0]);
  });
  return $('#result').empty().append(fragment);
};
preview_color = function() {
  var i, _results;
  $('#color-sample').empty();
  _results = [];
  for (i = 0; i <= 500; i++) {
    _results.push($('#color-sample').append($('<span>').attr('data-rate-index', i).css({
      display: 'inline-block',
      width: '1px',
      height: '30px',
      background: get_color(i / 500)
    })));
  }
  return _results;
};
$(function() {
  var completions_container, last, last_res, selected_token;
  last = '';
  last_res = null;
  setInterval(function() {
    var body;
    body = $('form').find('textarea').val();
    if (last === body) {
      return;
    }
    last = body;
    return $.post('/', {
      body: body,
      mime_type: 'application/ruby'
    }, function(res) {
      last_res = res;
      return highlight(res);
    });
  }, 1000);
  $('input[name="fill-type"]').change(function() {
    fill_pattern = $(this).val();
    preview_color();
    return highlight(last_res);
  });
  preview_color();
  selected_token = null;
  completions_container = $('#completions-container');
  $('.token').live('click', function(event) {
    selected_token = $(this).text();
    $('#result').css({
      background: '#ddd'
    });
    return $.post('/focus', {
      body: $('form').find('textarea').val(),
      focus: selected_token,
      mime_type: 'application/ruby'
    }, function(res) {
      $('#result').css({
        background: ''
      });
      last_res = res;
      return highlight(res);
    });
  });
  return $('#fill-factor').change(throttle(function(event) {
    fill_factor = $(this).val();
    preview_color();
    if (last_res) {
      return highlight(last_res);
    }
  }, 100));
});