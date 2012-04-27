/* DO NOT MODIFY. This file was compiled Wed, 18 May 2011 08:53:26 GMT from
 * /Users/supagroova/Development/rails/atreides/app/coffeescripts/comments.coffee
 */

(function() {
  var createInputCommentIds, getSelectedCommentId, post, _i, _len;
  $('#filter-list').change(function() {
    var self;
    console.log('go..');
    self = $(this);
    return setTimeout(function() {
      return self.submit();
    }, 30);
  });
  $('.comment').each(function(index, comment) {
    if (comment._loaded) {
      return true;
    }
    comment._loaded = true;
    return $(this).click(function(event) {
      comment = $(this);
      if ($(event.target).is('a,:input') || $(event.target).closest('a,:input').length > 0) {
        return true;
      }
      if (comment.hasClass('expanded')) {
        comment.removeClass('expanded');
      } else {
        comment.addClass('expanded').removeClass('unread');
      }
      return false;
    });
  });
  if ($('#expandall').hasClass('collapseall')) {
    for (_i = 0, _len = posts.length; _i < _len; _i++) {
      post = posts[_i];
      $('#comment-' + post.id).find('.comment-excerpt-block').click();
    }
  }
  $('.actions form input[type=button]').click(function() {
    var els;
    if (!_.isEmpty(getSelectedCommentId())) {
      els = createInputCommentIds();
      return $(this).parent('form').append(els).submit();
    } else {
      console.log("Please select at least one comment.");
      return false;
    }
  });
  createInputCommentIds = function() {
    var els;
    els = '';
    _.each(getSelectedCommentId(), function(cid) {
      return els += "<input type='hidden' name='comment_ids[]' value='" + cid + "'>";
    });
    return els;
  };
  getSelectedCommentId = function() {
    return _.map($('.comment-select input[type=checkbox]:checked'), function(el) {
      return $(el).attr("id").split("-")[1];
    });
  };
}).call(this);
