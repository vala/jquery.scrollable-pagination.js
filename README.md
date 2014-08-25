# jquery.scrollable-pagination.js

Basic infinite scroll jQuery plugin with only-next pagination, written in coffee and available in JS.

## Usage

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

### Data API

You may also not need to initialize the plugin manually if you set the following
`data-pagination="scrollable"` attribute on your container :

```html
<div data-pagination="scrollable" data-fetch-url="/pagination/url">
  <!-- data list here -->
</div>
```

### Previous page handling

You can optionnaly start at a given page, and be able to let Scrollable Pagination
load the previous pages for you.

The approach implemented is to have a button (any clickable DOM element) that will
trigger the previous page load, to avoid indefinitely loading pages without letting
the user reach the header bar.

You will have to add the button to your page, and pass a jQuery object targeting
it to the Scrollable Pagination initialization options.

```javascript
$('#my-list-container').scrollablePagination({
  previousDataButton: $('#my-previous-button')
  startPage: 5
})
```

You can also use the Data API to initialize those options, so you can easily
render those informations server-side :

```html
<button type="button" id="my-previous-button">
  Load previous items
</button>

<div data-pagination="scrollable" data-fetch-url="/pagination/url" data-previous-button="#my-previous-button" data-start-page="5">
  <!-- data list here -->
</div>
```

## Options

The following options are available :

* `fetchUrl`   : *(string)*   Sets the url that will be fetched when looking up for the next page

* `startPage`  : *(string)*   Sets the current page on plugin initialization, default is 1

* `loadingHintTemplate` : *(string)*  Allows setting an HTML template to be appended to the DOM while loading a new page

* `previousDataButton` : *(jQuery)*  Sets a jQuery object to listen clicks on, to load the previous page

Note that the javascript passed options will always override data-attribute defined ones.

## Events

For now there's only one event that's triggered from the plugin and it is fired
on the container element as a jQuery Event.

### `pageloaded`

When a new page is loaded, the `pageloaded` event is fired. You can listen it
with the following :

```javascript
$('#my-list-container').on('pageloaded', function(e, $markup) {
  // $markup is the HTML that was loaded from the server and wrapped in a
  // jQuery object to be appended to the DOM
  //
  // You can, for instance, add a class to all the loaded elements to show
  // them as newly loaded :
  $markup.addClass('new')
});
```

## Licence

The plugin is released under the MIT Licence, please use it !

