$.fn.tags = function(){
	var origin_element = this;

	var o = {
	  cache: {},
		e: null,
		ed: null,
		tags:[],

		init:function(){
			this.e = origin_element;
			var that = this;

			var n = $(this.e).next();
			if ( /jq_tags_editor/.test(n.attr('class')) )
			{
				this.ed = n.get(0);
			}
			else
			{
				$(this.e).after('<div class="jq_tags_editor"><span class="jq_tags_tokens"></span><input type="text" class="jq_tags_editor_input" /></div>');
				this.ed = $(this.e).next();
			}

			$(this.e).hide();
			$(this.ed)
				.unbind()
				.click(function(){
					$(that.ed).find('input').focus();
				})

			var tagInput = $(this.ed).find('input')
      tagInput
				.unbind()
				.blur(function(){
					that.add_tag();
				})
				.keydown(function(e){
				  if(e.keyCode == 13){
				    e.preventDefault();
			    }
				})
				.keyup(function(e){
					switch(e.keyCode){
						case 13:	// Return is pressed
						case 188:	// comma is pressed
							that.add_tag();
							break;
					}
				});

			tagInput.autocomplete({
			  source: function( request, response ) {
          var term = request.term;
          if ( term in that.cache ) {
            response( that.cache[ term ] );
            return;
          }

          $.getJSON( "/admin/tags/", request, function( data, status, xhr ) {
            that.cache[ term ] = data;
            response( data );
          });
        },
			  minLength: 1,
			  select: function(event, ui){

			  }
			})

			r = $(this.e).val().split(',');
			this.tags = []
			for(i in r)
			{
				r[i] = r[i].replace(/[",]/gi, '');
				if(r[i] != '')
				{	this.tags.push(r[i]);	}
			}
			this.refresh_list();
		},

		add_tag:function(){
		  var input = $(this.ed).find('input')
			var tag_txt = input.length ? input[0].value.replace(/[",]/gi, '') : '';

			if( (tag_txt != '') && (jQuery.inArray(tag_txt, this.tags) < 0) ){
				this.tags.push(tag_txt);
				this.refresh_list();
			}
			$(this.ed).find('input').val('').autocomplete("close");
		},
		remove_tag:function(tag_txt){
			r = [];
			for(i in this.tags){
				if(this.tags[i] != tag_txt)
				{	r.push(this.tags[i]);	}
			}
			this.tags = r;
			this.refresh_list();
		},
		refresh_list: function(){
			var that = this;

			$(this.ed).find('span.jq_tags_tokens').html('');
			$(this.e).val(this.tags.join(', '));

			h = '';
			for(i in that.tags){
				h += '<div class="jq_tags_token">' + that.tags[i] + '<a href="#">x</a></div>';
			}
			$(that.ed).find('input').val('');
			$(that.ed)
				.find('span.jq_tags_tokens')
					.html(h)
					.find('div.jq_tags_token')
						.find('a')
							.click(function(){
								var tag_txt = $(this).parents('.jq_tags_token:first').html().replace(/<a(.*?)<\/a>/, '');
								that.remove_tag(tag_txt);
							});
		}

	};
	o.init();
};
