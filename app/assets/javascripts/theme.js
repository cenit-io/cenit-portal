// 
//  Scripts for the theme, 
//  slideshow is used for Home Alt #4 (index4.html)
//  services is used for Services (services.html)
// 

$(function () {
  app_slideshow.initialize();
  home_slideshow.initialize();
  services.initialize();

  contactForm.initialize();


  // retina display
  if(window.devicePixelRatio >= 1.2){
      $("[data-2x]").each(function(){
          if(this.tagName == "IMG"){
              $(this).attr("src",$(this).attr("data-2x"));
          } else {
              $(this).css({"background-image":"url("+$(this).attr("data-2x")+")"});
          }
      });
  }
});

window.utils = {
  isFirefox: function () {
    return navigator.userAgent.toLowerCase().indexOf('firefox') > -1;
  }
};

var contactForm = {
  initialize: function () {
    var $contactForm = $("#contact-form");
    if (!$contactForm.length) {
      return;
    }
    $contactForm.validate({
      rules: {
        "contact_us_contact[name]": {
          required: true
        },
        "contact_us_contact[email]": {
          required: true,
          email: true
        },
        "contact_us_contact[message]": {
          required: true
        }
      },
      highlight: function (element) {
        $(element).closest('.form-group').removeClass('success').addClass('error')
      },
      success: function (element) {
        element.addClass('valid').closest('.form-group').removeClass('error').addClass('success')
      }
    });
  }
}

var services = {
  tabs: function () {
    $tabs = $("#services #tabs");
    $hexagons = $tabs.find(".hexagon");
    $sections = $tabs.find(".section");

    $hexagons.click(function () {
      $hexagons.removeClass("active");
      $(this).addClass("active");
      var index = $hexagons.index(this);
      $sections.fadeOut();
      $sections.eq(index).fadeIn();
    });
  },
  screenHover: function () {
    $screens = $("#features-hover .images img");
    $features = $("#features-hover .features .feature");
    $features.mouseenter(function () {
      if (!$(this).hasClass("active")) {
        $features.removeClass("active");
        $(this).addClass("active");
        var index = $features.index(this);
        $screens.stop().fadeOut();
        $screens.eq(index).fadeIn();
      }     
    });
  },
  initialize: function () {
    this.tabs();
    this.screenHover();
  }
}

var home_slideshow = {
  initialize: function () {
    var $slideshow = $("#home #slider .slide-wrapper .slideshow"),
      $slides = $slideshow.find(".slide"),
      $btnPrev = $slideshow.find(".btn-nav.prev"),
      $btnNext = $slideshow.find(".btn-nav.next");

    var index = 0;
    var interval = setInterval(function () {
      index++;
      if (index >= $slides.length) {
        index = 0;
      }
      updateSlides(index);
    }, 4500);

    $btnPrev.click(function () {
      clearInterval(interval);
      interval = null;
      index--;
      if (index < 0) {
        index = $slides.length - 1;
      }
      updateSlides(index);
    });

    $btnNext.click(function () {
      clearInterval(interval);
      interval = null;
      index++;
      if (index >= $slides.length) {
        index = 0;
      }
      updateSlides(index);
    });

    $slideshow.hover(function () {
      $btnPrev.addClass("active");
      $btnNext.addClass("active");
    }, function () {
      $btnPrev.removeClass("active");
      $btnNext.removeClass("active");
    });


    function updateSlides(index) {
      $slides.removeClass("active");
      $slides.eq(index).addClass("active");
    }
  }
}

var app_slideshow = {
  initialize: function () {
    var $slideshow = $("#apps #slider .slide-wrapper .slideshow"),
      $slides = $slideshow.find(".slide"),
      $btnPrev = $slideshow.find(".btn-nav.prev"),
      $btnNext = $slideshow.find(".btn-nav.next");

    var index = 0;
    var interval = setInterval(function () {
      index++;
      if (index >= $slides.length) {
        index = 0;
      }
      updateSlides(index);
    }, 2333);

    $btnPrev.click(function () {
      clearInterval(interval);
      interval = null;
      index--;
      if (index < 0) {
        index = $slides.length - 1;
      }
      updateSlides(index);
    });

    $btnNext.click(function () {
      clearInterval(interval);
      interval = null;
      index++;
      if (index >= $slides.length) {
        index = 0;
      }
      updateSlides(index);
    });

    $slideshow.hover(function () {
      $btnPrev.addClass("active");
      $btnNext.addClass("active");
    }, function () {
      $btnPrev.removeClass("active");
      $btnNext.removeClass("active");
    });


    function updateSlides(index) {
      $slides.removeClass("active");
      $slides.eq(index).addClass("active");
    }
  }
}

$(function(){
    var current = 'weekly';

    $('#charts').find('.tabs .tab').click(function() {
        if (!($(this).hasClass('active'))) {
            $(this).addClass('active');
            $('#charts').find('.tabs .tab.'+current).removeClass('active');
            $('#charts').find('.plans').removeClass(current);
            if (current == 'weekly')
                current = 'monthly';
            else
                current = 'weekly';
            $('#charts').find('.plans').addClass(current);
        }
    });
});

$(function() {
    var logged_in = $("#sign-in-link").length == 0;

    if (!logged_in)
        var tour = new Tour({
            name: 'anonymous',
            steps: [
                {
                    title: "Welcome to Cenit",
                    content: "Thanks for visiting us! Click 'Next' to start the tour.",
                    orphan: true,
                    backdrop: true
                },
                {
                    element: "#cover-image .button_hub",
                    title: "Data Integrator",
                    content: "Connect with hundreds of online systems with ease.",
                    placement: "left"
                },
                {
                    element: "#cover-image .button_erp",
                    title: "ERP & CRM",
                    content: "Manage your hole business without spending on infrastructure."
                },
                {
                    element: "#grid-first form #name",
                    title: "Over 900 apps",
                    content: "Checkout our plethora of third-party apps you can integrate in your system.",
                    placement: "bottom"
                },
                {
                    element: "#sign-in-link",
                    title: "Start now",
                    content: "Register a new account for free!",
                    placement: "bottom"
                }
            ]});
    else
        var tour = new Tour({
            name: 'registered',
            steps: [
                {
                    title: "Thank you for choosing Cenit!",
                    content: "This short tour will show you our main features, feel free to contact us anyway! Click 'Next' to begin the tour.",
                    orphan: true,
                    backdrop: true
                },
                {
                    element: "#cover-image .button_hub",
                    title: "Data Integrator",
                    content: "Go to your very own Hub tenant, and start integrating with third-party online systems.",
                    placement: "left"
                },
                {
                    element: "#cover-image .button_erp",
                    title: "ERP & CRM",
                    content: "Create a new Odoo tenant with many addons available, including integration addons via yur Hub."
                },
                {
                    element: "#devise_messages",
                    title: "Notifications",
                    content: "Don't forget to check this area for notifications.",
                    placement: "bottom"
                },
                {
                    element: "#pricing",
                    title: "Multiple choices",
                    content: "The free plan doesn't cut it for you? Check out our Variable and Enterprise features!.",
                    placement: "top"
                },
                {
                    element: "#charts",
                    title: "Development services",
                    content: "If you are targeting an app we currently don't support let us know so we can make it happen for you.",
                    placement: "top"
                }
            ]});

// Initialize the tour
    console.log("Initializing tour");
    tour.init(true);

// Start the tour
    console.log("Starting tour");
    tour.start(true);
});