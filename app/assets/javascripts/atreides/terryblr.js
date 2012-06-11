/*
 * Atreides - Public Behaviours
 *
 * Lachlan Laycock @ Jackson Laycock
 * 04 March 2010
 *
 */
 $(document).ready(function() {
  // Add loading class to all links when clicked on - use CSS to style
  $('a').click(function(e) {
    $(this).addClass('loading')
  })
  // Remove loading class to all links when AJAX finished - use CSS to style
  $('a').ajaxComplete(function(e) {
    $(this).removeClass('loading');
  });

  // Slideshow
  slideshow = $('.slideshow')
  if (slideshow.length) {
    slideshow.cycle({ fx: 'fade', timeout: 0 })

    // Pause if details page
    if (slideshow.parents('body.posts-show').length) {
      slideshow.cycle({ timeout: 0 })
    }

    $('.slideshow_controls a').each(function(i, el) {
      // Show each slide
      $(el).click(function(e) { slideshow.cycle(i); return false; })
    })
   }

   // Cart Items display
   if ((cart = $('#cart_items')).length > 0) {
     // Is cookie set?
     if (items = $.cookie('cart_items')) {
       $('#cart_items a').append(' ('+items.split('&').length+' items)')
     }
   }

   // Auto-hide fields
   auto_hides = $('.auto-hide-text input[type=text]')
   if (auto_hides.length > 0) {
     auto_hides.each(function(i, el) { $(el).attr('default',$(el).val()) })
     auto_hides.focus(function(e) {
       if ($(this).val()==$(this).attr('default')) $(this).val('')
       $(this).attr('style', 'color:#000');
     })
     auto_hides.blur(function(e) {
       if ($(this).val().length==0) {
         $(this).val($(this).attr('default'))
         $(this).attr('style', '');
       }
     })
   }
});
