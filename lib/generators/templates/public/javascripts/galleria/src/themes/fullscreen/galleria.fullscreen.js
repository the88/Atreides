/*
 * Galleria Fullscreen Theme v. 2.2 2010-10-28
 * http://galleria.aino.se
 *
 * Copyright (c) 2010, Aino
 * Licensed under the MIT license.
 */

(function($) {

Galleria.addTheme({
    name: 'fullscreen',
    author: 'Galleria',
    version: '2.2',
    css: 'galleria.fullscreen.css',
    defaults: {
        data_selector: "a",
        data_config: function(a) {
            // a is now the anchor element
            // the function should return an object with the new data
            return {
                image: $(a).attr('href'), // tell Galleria that the href is the main image,
                thumb: $(a).find('img').attr('src')
            };
        },
        thumb_crop: 'height',
        // set this to false if you want to keep the thumbnails:
        _hide_dock: false,
        // set this to true if you want to shrink the carousel when clicking a thumbnail:
        _close_on_click: false
    },
    init: function(options) {

        this.addElement('thumbnails-tab');
        this.appendChild('thumbnails-container', 'thumbnails-tab');

        var tab      = this.$('thumbnails-tab'),
            loader   = this.$('loader'),
            thumbs   = this.$('thumbnails-container'),
            list     = this.$('thumbnails-list'),
            infotext = this.$('info-text'),
            info     = this.$('info'),
            OPEN     = !options._hide_dock,
            POS      = 0,
            CLICK    = Galleria.TOUCH ? 'touchstart' : 'click';

        if (Galleria.IE) {
            this.addElement('iefix');
            this.appendChild('container', 'iefix');
            this.$('iefix').css({
                zIndex: 3,
                position: 'absolute',
                backgroundColor: '#000',
                opacity: .4
            });
        }

        if ( options.thumbnails === false ) {
            thumbs.hide();
        }

        var fixCaption = this.proxy(function(img) {

            if (!(img || img.width)) {
                return;
            }
            var w = Math.min(img.width, $(window).width());
            infotext.width(w - 40);
            if (Galleria.IE && this.getOptions('show_info')) {
                this.$('iefix').width(info.outerWidth()).height(info.outerHeight());
            }
        });
        this.bind(Galleria.RESCALE, function() {
            POS = this.getStageHeight() - tab.height() - 2;
            thumbs.css('top', OPEN ? POS - list.outerHeight() + 2 : POS);
            var img = this.getActiveImage();
            if (img) {
                fixCaption(img);
            }
        });

        this.bind(Galleria.LOADSTART, function(e) {
            if (!e.cached) {
                loader.show().fadeTo(100, 1);
            }
            $(e.thumbTarget).css('opacity', 1).parent().siblings().children().css('opacity', .6);
        });

        this.bind(Galleria.LOADFINISH, function(e) {
            loader.fadeOut(300);
            this.$('info, iefix').toggle(this.hasInfo());
        });

        this.bind(Galleria.IMAGE, function(e) {
            fixCaption(e.imageTarget);
            $('#img_title').text(function() {
              var info = $('.galleria-info-title').text()
              if (info != "") {
                return info;
              } else {
                return (Galleria.get(0).getIndex() + 1);
              }
            });
            
            // $('.galleria-image-nav-right, .galleria-image-nav-left').stop().delay(1000).animate({opacity: 0}, 600);
        });

        this.bind(Galleria.THUMBNAIL, function(e) {
            $(e.thumbTarget).parent(':not(.active)').children().css('opacity', .6);
            $(e.thumbTarget).click(function() {
                if (OPEN && options._close_on_click) {
                    tab.click();
                }
            });
        });

        this.trigger(Galleria.RESCALE);

        this.addIdleState(thumbs, { opacity: 0 });
        this.addIdleState(this.get('info'), { opacity: 0 });

        if (Galleria.IE) {
            this.addIdleState(this.get('iefix'), { opacity: 0 });
        }
         
        // this.$('image-nav-left, image-nav-right').css('opacity', 1).hover(function() {
        //     $(this).animate({opacity: 1}, 100);
        // }, function() {
        //     $(this).animate({opacity: 0});
        // }).show();

        if (options._hide_dock) {
            tab.click(this.proxy(function() {
                tab.toggleClass('open', !OPEN);
                if (!OPEN) {
                    thumbs.animate({
                        top: POS - list.outerHeight() + 2
                    }, 400, 'galleria');
                } else {
                    thumbs.animate({
                        top: POS
                    }, 400, 'galleria');
                }
                OPEN = !OPEN;
            }));
        } else {
            this.bind(Galleria.THUMBNAIL, function() {
                thumbs.css('top', POS - list.outerHeight() + 2);
            });
            tab.css('visibility', 'hidden');
        }

        this.$('thumbnails').children().hover(function() {
            $(this).not('.active').children().stop().fadeTo(100, 1);
        }, function() {
            $(this).not('.active').children().stop().fadeTo(400, .6);
        });
        
        $('.galleria-image-nav-right, .galleria-image-nav-left').hover(function() {
          $('.galleria-image-nav-right, .galleria-image-nav-left').stop().animate({opacity: 1}, "fast");
          console.log("ENTER");
        },
        function () {
          $('.galleria-image-nav-right, .galleria-image-nav-left').stop().animate({opacity: .4}, 600);
          console.log("LEAVE");
        });

        this.enterFullscreen();
        this.attachKeyboard({
            escape: function(e) {
                return false;
            },
            up: function(e) {
                if (!OPEN) {
                    tab.click();
                }
                e.preventDefault();
            },
            down: function(e) {
                if (OPEN) {
                    tab.click();
                }
                e.preventDefault();
            }
        });
        $('.galleria-image-nav').children().wrapAll('<div class="img-nav-container" />');
        $('.galleria-image-nav-right, .galleria-image-nav-left').stop().delay(3000).animate({opacity: .4}, 600);
        $('.galleria-container').css('min-height', '430px');
        $('.galleria-container').css('visibility', 'visible');
    }
});

})(jQuery);
