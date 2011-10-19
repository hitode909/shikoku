var color_sample_length, create_token, fill_factor, fill_pattern, get_color, highlight, highlight_histogram, preview_color, preview_color_by_summary, round_list, throttle;
fill_pattern = 'color';
fill_factor = 180.0;
color_sample_length = 500;
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
highlight_histogram = function(res) {
  var fragment, i, list, summary;
  fragment = document.createDocumentFragment();
  summary = {};
  $.each(res.tokens, function(i, data) {
    var index, _ref;
    if (!data.value.match(/\S/)) {
      return;
    }
    index = Math.floor(data.rate * color_sample_length);
    if ((_ref = summary[index]) == null) {
      summary[index] = 0;
    }
    return summary[index] += 1 / res.tokens.length;
  });
  list = [];
  for (i = 0; 0 <= color_sample_length ? i <= color_sample_length : i >= color_sample_length; 0 <= color_sample_length ? i++ : i--) {
    list[i] = summary[i] || 0;
  }
  return preview_color_by_summary(round_list(list, 200));
};
round_list = function(list, range) {
  var i, j, res, v, _ref, _ref2, _ref3;
  res = [];
  for (i = 0, _ref = list.length - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
    v = 0;
    for (j = _ref2 = Math.floor(i - range * 0.5), _ref3 = Math.floor(i + range * 0.5); _ref2 <= _ref3 ? j <= _ref3 : j >= _ref3; _ref2 <= _ref3 ? j++ : j--) {
      if (0 <= j && j < list.length && list[j] > 0) {
        v += list[j] * Math.pow(0.9, Math.abs(i - j));
      }
    }
    res[i] = v;
  }
  return res;
};
highlight = function(res) {
  var focus, fragment, total;
  fragment = document.createDocumentFragment();
  total = res.total;
  focus = res.focus;
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
  $('#result').empty().append(fragment);
  return highlight_histogram(res);
};
preview_color = function() {
  var i, _results;
  $('#color-sample').empty();
  _results = [];
  for (i = 0; 0 <= color_sample_length ? i <= color_sample_length : i >= color_sample_length; 0 <= color_sample_length ? i++ : i--) {
    _results.push($('#color-sample').append($('<span>').attr('data-rate-index', i).css({
      background: get_color(i / color_sample_length)
    })));
  }
  return _results;
};
preview_color_by_summary = function(summary) {
  var height, i, _results;
  $('#color-sample').empty();
  _results = [];
  for (i = 0; 0 <= color_sample_length ? i <= color_sample_length : i >= color_sample_length; 0 <= color_sample_length ? i++ : i--) {
    height = 200 * (Math.log(summary[i] + 1) / Math.log(2.0));
    _results.push($('#color-sample').append($('<span>').attr('data-rate-index', i).css({
      height: "" + height + "px",
      background: get_color(i / color_sample_length + 0.0001)
    })));
  }
  return _results;
};
$(function() {
  var completions_container, last, last_res, selected_token;
  last = '';
  last_res = null;
  fill_factor = $('#fill-factor').val();
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