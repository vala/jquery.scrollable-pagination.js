class ScrollablePagination
  constructor: (@container, options = {}) ->
    @initialize(options)

  initialize: (options = {}) ->
    # Page starts at 1 as a default
    @page = options.start_page || 1
    # Fetch URL can be passed in options or in @container's fetch-url data attr.
    @fetch_url = options.fetch_url || @container.data('fetch-url')

    # Set scrollable container which we will be listening scroll on
    @scrollable_container = switch
      when options.scrollable_container == null then @container
      when options.scrollable_container then $(options.scrollable_container)
      else $(window)

    # Callback when next page added to DOM
    @afterLoaded = options.afterLoaded

    # Start loading when scroll at 200px of scrollable_container's end
    @scroll_offset = 200
    # If we have no more content to read
    @done = false
    @last_scroll_handling_call = +(new Date())
    # Set loading state to false
    @loading = false
    # Bin all events
    @bindAll()

  bindAll: ->
    @scrollable_container.on 'scroll', => @handleScroll()

  handleScroll: ->
    return if @done

    # Don't handle scroll to often ! Every 500ms minimum
    time = +(new Date())
    return @resetScrollTimer(time) if (time - @last_scroll_handling_call) < 200 || @done

    @last_scroll_handling_call = time

    top = @scrollable_container.scrollTop()
    threshold = @loadThreshold()
    # If scroll position is sufficient and we're not loading yet
    if top > threshold && !@loading
      # initialize nex data set loading process
      @loadNextDataSet()

  resetScrollTimer: (now) ->
    clearTimeout(@scroll_timer) if @scroll_timer
    @scroll_timer = setTimeout((=> @handleScroll()), 200)

  # Get current scroll threshold at which we should start loading next page
  loadThreshold: ->
    (@container.innerHeight() + @container.offset().top) -
      (@scrollable_container.innerHeight() + @scroll_offset)

  loadNextDataSet: ->
    @setLoading true
    # Load page
    $.get(
      @pageUrl ++@page
      (resp) => @nextPageLoaded resp
      'html'
    )

  nextPageLoaded: (resp) ->
    @setLoading false
    if resp
      $markup = $(resp).appendTo(@container)
      @afterLoaded($markup) if $.isFunction(@afterLoaded)
    else
      @done = true

  # Set loading state and reflect it accordingly into DOM
  setLoading: (@loading) ->
    if @loading
      @container.addClass('loading')
        .append(
          $('<div/>').addClass('scrollable-pagination-loader')
            .text('Loading content ...')
        )
    else
      @container.removeClass('loading')
        .find('.scrollable-pagination-loader').remove()

  pageUrl: (page) ->
    if @fetch_url.match /:page/
      @fetch_url.replace /:page/, page
    else
      url = @fetch_url
      url += if url.match /\?/ then '&' else '?'
      url += "page=#{ page }"

  # Reset alias for re-initialization of the plugin state
  reset: (options = {}) ->
    @initialize(options)


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
      new ScrollablePagination($this, options)
    )