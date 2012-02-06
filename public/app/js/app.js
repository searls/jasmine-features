$(function(){
  $('#submitButton').on('click', function() {
    $('body').append('<span>Submitted!</span>')
  })

  $('body').append('<span>Loaded!</span>')
})