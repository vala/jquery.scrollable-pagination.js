jquery.scrollable-pagination.js
===============================

Basic infinite scroll jQuery plugin with only-next pagination, written in coffee and available in JS.

Usage
=====

Let's say we have a simple div container.
We can tell scrollablePagination which url to fetch when looking for pages.
Here, the url fetched will be `/pagination/url?page=n` where n is the infered page that the plugin thinks is the next.

```html
<div id="my-list-container" data-fetch-url="/pagination/url">
  <!-- data list here -->
</div>
```

Then, initialize the plugin from javascript.

```javascript
$('#my-list-container').scrollablePagination(options)
```

The plugins doesn't care about what contains the returned HTML, while it's HTML markup.

Options
=======

The following options are available :

* `fetch_url`   : *(string)*   Sets the url that will be fetched when looking up for the next page

* `start_page`  : *(string)*   Sets the current page on plugin initialization, default is 1

* `afterLoaded` : *(function)* Callback to be called when the next markup has been loaded and appended to the container. It is passed the received markup jQuery object.
  > e.g. `afterLoaded: function($markup) { $markup.addClass('new'); }`


Note that the javascript passed options will always override data-attribute defined ones.

Licence
=======

The plugin is released under the MIT Licence, please use it !

