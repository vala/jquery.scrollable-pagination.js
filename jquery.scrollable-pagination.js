// jQuery.scrollablePagination version 0.1
(function() {
  var ScrollablePagination;

  ScrollablePagination = (function() {

    function ScrollablePagination(container, options) {
      this.container = container;
      if (options == null) {
        options = {};
      }
      this.initialize(options);
    }

    ScrollablePagination.prototype.initialize = function(options) {
      if (options == null) {
        options = {};
      }
      this.page = options.start_page || 1;
      this.fetch_url = options.fetch_url || this.container.data('fetch-url');
      this.scrollable_container = (function() {
        switch (false) {
          case options.scrollable_container !== null:
            return this.container;
          case !options.scrollable_container:
            return $(options.scrollable_container);
          default:
            return $(window);
        }
      }).call(this);
      this.afterLoaded = options.afterLoaded;
      this.scroll_offset = 200;
      this.done = false;
      this.last_scroll_handling_call = +(new Date());
      this.loading = false;
      return this.bindAll();
    };

    ScrollablePagination.prototype.bindAll = function() {
      var _this = this;
      return this.scrollable_container.on('scroll', function() {
        return _this.handleScroll();
      });
    };

    ScrollablePagination.prototype.handleScroll = function() {
      var threshold, time, top;
      if (this.done) {
        return;
      }
      time = +(new Date());
      if ((time - this.last_scroll_handling_call) < 200 || this.done) {
        return this.resetScrollTimer(time);
      }
      this.last_scroll_handling_call = time;
      top = this.scrollable_container.scrollTop();
      threshold = this.loadThreshold();
      if (top > threshold && !this.loading) {
        return this.loadNextDataSet();
      }
    };

    ScrollablePagination.prototype.resetScrollTimer = function(now) {
      var _this = this;
      if (this.scroll_timer) {
        clearTimeout(this.scroll_timer);
      }
      return this.scroll_timer = setTimeout((function() {
        return _this.handleScroll();
      }), 200);
    };

    ScrollablePagination.prototype.loadThreshold = function() {
      return (this.container.innerHeight() + this.container.offset().top) - (this.scrollable_container.innerHeight() + this.scroll_offset);
    };

    ScrollablePagination.prototype.loadNextDataSet = function() {
      var _this = this;
      this.setLoading(true);
      return $.get(this.pageUrl(++this.page), function(resp) {
        return _this.nextPageLoaded(resp);
      }, 'html');
    };

    ScrollablePagination.prototype.nextPageLoaded = function(resp) {
      var $markup;
      this.setLoading(false);
      if (resp) {
        $markup = $(resp).appendTo(this.container);
        if ($.isFunction(this.afterLoaded)) {
          return this.afterLoaded($markup);
        }
      } else {
        return this.done = true;
      }
    };

    ScrollablePagination.prototype.setLoading = function(loading) {
      this.loading = loading;
      if (this.loading) {
        return this.container.addClass('loading').append($('<div/>').addClass('scrollable-pagination-loader').text('Loading content ...'));
      } else {
        return this.container.removeClass('loading').find('.scrollable-pagination-loader').remove();
      }
    };

    ScrollablePagination.prototype.pageUrl = function(page) {
      var url;
      if (this.fetch_url.match(/:page/)) {
        return this.fetch_url.replace(/:page/, page);
      } else {
        url = this.fetch_url;
        url += url.match(/\?/) ? '&' : '?';
        return url += "page=" + page;
      }
    };

    ScrollablePagination.prototype.reset = function(options) {
      if (options == null) {
        options = {};
      }
      return this.initialize(options);
    };

    return ScrollablePagination;

  })();

  (function($) {
    return $.fn.scrollablePagination = function(options) {
      var $this, data;
      $this = $(this);
      data = $this.data('scrollable-pagination');
      if (data) {
        return data;
      }
      return $this.data('scrollable-pagination', new ScrollablePagination($this, options));
    };
  })(jQuery);

}).call(this);
