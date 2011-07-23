var create_token, fill_pattern, get_color, highlight, last_res, preview_color;
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
    l = (1 - level * level) * 50;
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
  var fragment, max, total;
  fragment = document.createDocumentFragment();
  total = res.total;
  max = 0.01;
  $.each(res.tokens, function(i, data) {
    var node;
    node = create_token(data);
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
  var completions_container, last, selected_token;
  last = '';
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
    var loading;
    if (selected_token && $(event.target).parents('#completions-container').length > 0) {
      selected_token.replaceWith($(this));
      selected_token = null;
      completions_container.hide();
      return true;
    }
    selected_token = $(this);
    completions_container.empty().show();
    completions_container.css({
      left: $(this).position().left + 20,
      top: $(this).position().top + 20
    });
    loading = $('<div>').text('...').css('class', 'loading');
    completions_container.append($('<strong>').append($(this).clone(true))).append($('<hr>')).append(loading);
    return $.get('/suggest', {
      token: $(this).text()
    }, function(res) {
      var item, _i, _len, _results;
      loading.remove();
      _results = [];
      for (_i = 0, _len = res.length; _i < _len; _i++) {
        item = res[_i];
        _results.push(completions_container.append($('<div>').append(create_token(item))));
      }
      return _results;
    });
  });
  return $('body').click(function(event) {
    if (!$(event.target).parents('#completions-container').length) {
      completions_container.hide();
      return selected_token = null;
    }
  });
});