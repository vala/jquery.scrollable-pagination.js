ScrollablePagination = {}

class ScrollablePagination.Container
  constructor: (@$el, options = {}) ->
    @initialize(options)

  initialize: (options = {}) ->
    @originalOptions = $.extend({}, options)
    # Page starts at 1 as a default
    options.startPage ?= @$el.data('start-page') or 1
    # Fetch URL can be passed in options or in @$el's fetch-url data attr.
    @fetchUrl = options.fetchUrl or @$el.data('fetch-url')

    new ScrollablePagination.NextPageHandler(@$el, this, options)
    new ScrollablePagination.PreviousPageHandler(@$el, this, options)

  loadPage: (page, callback) ->
    $.get(
      @pageUrl(page)
      (resp) => callback($.trim(resp))
      'html'
    )

  pageUrl: (page) ->
    if @fetchUrl.match /:page/
      @fetchUrl.replace /:page/, page
    else
      url = @fetchUrl
      url += if url.match /\?/ then '&' else '?'
      url += "page=#{ page }"

  # Reset alias for re-initialization of the plugin state
  reset: (options) ->
    @initialize(options || @originalOptions)


class ScrollablePagination.NextPageHandler
  _loadingHintTemplate: (options) -> """
    <div class="scrollable-pagination-loader">
      #{ options.loadingText }
    </div>
  """

  constructor: (@$el, @container, options) ->
    @page = options.startPage
    # Set scrollable container which we will be listening scroll on
    @scrollableContainer = switch
      when options.scrollableContainer is null then @$el
      when options.scrollableContainer then $(options.scrollableContainer)
      else $(window)
    # Start loading when scroll at 200px of scrollableContainer's end
    @scrollOffset = options.scrollOffset || 200
    # If we have no more content to read
    @done = false
    @lastScrollHandlingCall = +(new Date())
    # Set loading state to false
    @loading = false
    @loadingText = options.loadingText || 'Loading more ...'
    @loadingHintTemplate = options.loadingHintTemplate || @_loadingHintTemplate(
      loadingText: loadingText
    )

    @scrollableContainer.on 'scroll', => @handleScroll()

  handleScroll: ->
    return if @done

    # Don't handle scroll to often ! Every 200ms minimum
    time = +(new Date())
    return @resetScrollTimer(time) if (time - @lastScrollHandlingCall) < 200 || @done

    @lastScrollHandlingCall = time

    top = @scrollableContainer.scrollTop()
    threshold = @loadThreshold()
    # If scroll position is sufficient and we're not loading yet
    if top > threshold && !@loading
      # initialize nex data set loading process
      @loadNextDataSet()

  resetScrollTimer: (now) ->
    clearTimeout(@scrollTimer) if @scrollTimer
    @scrollTimer = setTimeout((=> @handleScroll()), 200)

  # Get current scroll threshold at which we should start loading next page
  loadThreshold: ->
    (@$el.innerHeight() + @$el.offset().top) -
      (@scrollableContainer.innerHeight() + @scrollOffset)

  loadNextDataSet: ->
    @setLoadingState()
    @container.loadPage(++@page, (markup) => @nextPageLoaded(markup))

  nextPageLoaded: (markup) ->
    @removeLoadingState()
    return (@done = true) unless markup
    $markup = $(markup).appendTo(@$el)
    @$el.trigger("pageloaded", [$markup])

  setLoadingState: ->
    @loading = true
    @$el.addClass('loading')
    $(@loadingHintTemplate).appendTo(@$el)

  removeLoadingState: ->
    @loading = false
    @$el.removeClass('loading')
      .find('.scrollable-pagination-loader').remove()


class ScrollablePagination.PreviousPageHandler
  constructor: (@$el, @container, options) ->
    @page = options.startPage
    # If we have no more content to read
    @done = @page is 1
    # Set loading state to false
    @loading = false

    @$previousDataButton = if options.previousDataButton
      options.previousDataButton
    else if (target = @$el.data('previous-button') and ($target = $(target)).length))
      $target


    @$previousDataButton.on('click', (e) => @previousDataButtonClicked(e))

  previousDataButtonClicked: (e) ->
    @loadPrevousDataSet()
    false

  loadPrevousDataSet: ->
    return if @done
    @setLoadingState()
    @container.loadPage(--@page, (markup) => @previousPageLoaded(markup))
    if @page is 1
      @done = true
      @$previousDataButton.remove()

  previousPageLoaded: (markup) ->
    @removeLoadingState()
    $firstChildren = @$el.children().eq(0)
    scrollOffset = $firstChildren.offset().top - $(window).scrollTop()
    $markup = $(markup).prependTo(@$el)
    $(window).scrollTop($firstChildren.offset().top - scrollOffset)
    @$el.trigger("pageloaded", [$markup])

  setLoadingState: ->
    @loading = true
    @$el.addClass('loading')
    @$previousDataButton.addClass('loading')

  removeLoadingState: ->
    @loading = false
    @$el.removeClass('loading')
    @$previousDataButton.removeClass('loading')

# jQuery plugin access and caching
do ($ = jQuery) ->
  $.fn.scrollablePagination = (options) ->
    $this = $(this)
    # Check if a cached ScrollablePagination instance exist
    data = $this.data('scrollable-pagination')
    # If a cached instance exists, use it instead of creating a new one
    return data if data
    # Create ScrollablePagination item and cache it
    $this.data(
      'scrollable-pagination',
      new ScrollablePagination.Container($this, options)
    )

  # Data api
  $ ->
    $("[data-pagination='scrollable']").each (i, element) ->
      $el = $(element)
      $el.scrollablePagination(fetchUrl: $el.data("fetch-url"))
