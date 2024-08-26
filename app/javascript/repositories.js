document.addEventListener('DOMContentLoaded', function() {
  $('.campus_link').click(function() {
    if (location.pathname.replace(/^\//,'') == this.pathname.replace(/^\//,'') && location.hostname == this.hostname) {
      var target = $(this.hash);
      target = target.length ? target : $('[name=' + this.hash.slice(1) +']');
      if (target.length) {
        $('html,body').animate({
          scrollTop: target.offset().top - 160
        }, 1000);
        return false;
      }
    }
  });

  $(window).scroll(function(){
    if ($(this).scrollTop() > 600) {
        $(".scrollToTop").fadeIn(1000)
    } else {
        $(".scrollToTop").fadeOut(1000);
    }
  });

  //Click event to scroll to top
  $(".scrollToTop").click(function(){
      $('html, body').animate({scrollTop : 0},500);
      return false;
  });
});
