(function() {
  $.fn.accordion = function(opts) {
    var contents, defaults, e, element, eventsMap, first, options, show, _i, _len, _ref;
    element = this;
    defaults = {
      accordionHeader: '.accordion.header',
      accordionContents: '.accordion.contents',
      slideDuration: 'normal',
      events: ['click', 'dblclick']
    };
    options = $.extend(defaults, opts);
    if (typeof options.events === 'string') {
      options.events = [options.events];
    }
    contents = this.find(options.accordionContents);
    first = contents.first();
    contents.not(first).hide();
    show = function(ev) {
      var content;
      content = $(ev.target).next(options.accordionContents);
      if (content.is(':hidden')) {
        element.find(options.accordionContents).not(content).slideUp(options.slideDuration);
        return content.slideToggle(options.slideDuration);
      }
    };
    eventsMap = {};
    _ref = options.events;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      e = _ref[_i];
      eventsMap[e] = show;
    }
    return this.find(options.accordionHeader).bind(eventsMap);
  };
  $(function() {
    return $('body').accordion({
      slideDuration: 'fast'
    });
  });
}).call(this);
