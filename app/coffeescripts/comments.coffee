$('#filter-list').change () ->
  console.log 'go..'
  self = $(this) 
  setTimeout () ->
    self.submit()
  , 30

# set up comment expand/collapse links.
$('.comment').each (index, comment) ->
  # Don't create a new event for comments that have already been loaded.
  return true if comment._loaded
  comment._loaded = true;
  
  $(this).click (event) ->
    comment = $(this)
    
    # Allow any user interact-able object (links, inputs, etc.) to function normally.
    if ($(event.target).is('a,:input') || $(event.target).closest('a,:input').length > 0)
      return true
    
    if (comment.hasClass('expanded'))
      comment.removeClass('expanded')
    else
      comment.addClass('expanded').removeClass('unread')
    return false
  
if $('#expandall').hasClass('collapseall')
  for post in posts
    $('#comment-' + post.id).find('.comment-excerpt-block').click()

# $('.comment').live 'click', () ->
#   $(this).toggleClass "expanded"

$('.actions form input[type=button]').click () ->
  unless _.isEmpty getSelectedCommentId()
    els = createInputCommentIds()
    $(this).parent('form').append(els).submit()
  else
    console.log "Please select at least one comment."
    return false

createInputCommentIds = () ->
  els = ''
  _.each getSelectedCommentId(), (cid) ->
    els += "<input type='hidden' name='comment_ids[]' value='" + cid + "'>"
  return els

getSelectedCommentId = () ->
  _.map $('.comment-select input[type=checkbox]:checked'), (el) ->
    $(el).attr("id").split("-")[1]