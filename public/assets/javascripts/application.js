// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap-sprockets
//= require_tree .

$.fn.pageMe = function(opts){
  var $this = this,
      defaults = {
          perPage: 20,
          showPrevNext: false,
          hidePageNumbers: false
      },
      settings = $.extend(defaults, opts);
  
  var listElement = $this;
  var perPage = settings.perPage; 
  var children = listElement.children();
  var pager = $('.pager');
  
  if (typeof settings.childSelector!="undefined") {
      children = listElement.find(settings.childSelector);
  }
  
  if (typeof settings.pagerSelector!="undefined") {
      pager = $(settings.pagerSelector);
  }
  
  var numItems = children.size();
  var numPages = Math.ceil(numItems/perPage);

  pager.data("curr",0);
  
  if (settings.showPrevNext){
      $('<li><a href="#" class="prev_link">«</a></li>').appendTo(pager);
  }
  
  var curr = 0;
  while(numPages > curr && (settings.hidePageNumbers==false)){
      $('<li><a href="#" class="page_link">'+(curr+1)+'</a></li>').appendTo(pager);
      curr++;
  }
  
  if (settings.showPrevNext){
      $('<li><a href="#" class="next_link">»</a></li>').appendTo(pager);
  }
  
  pager.find('.page_link:first').addClass('active');
  pager.find('.prev_link').hide();
  if (numPages<=1) {
      pager.find('.next_link').hide();
  }
  pager.children().eq(1).addClass("active");
  
  children.hide();
  children.slice(0, perPage).show();
  
  pager.find('li .page_link').click(function(){
      var clickedPage = $(this).html().valueOf()-1;
      goTo(clickedPage,perPage);
      return false;
  });
  pager.find('li .prev_link').click(function(){
      previous();
      return false;
  });
  pager.find('li .next_link').click(function(){
      next();
      return false;
  });
  
  function previous(){
      var goToPage = parseInt(pager.data("curr")) - 1;
      goTo(goToPage);
  }
   
  function next(){
      goToPage = parseInt(pager.data("curr")) + 1;
      goTo(goToPage);
  }
  
  function goTo(page){
      var startAt = page * perPage,
          endOn = startAt + perPage;
      
      children.css('display','none').slice(startAt, endOn).show();
      
      if (page>=1) {
          pager.find('.prev_link').show();
      }
      else {
          pager.find('.prev_link').hide();
      }
      
      if (page<(numPages-1)) {
          pager.find('.next_link').show();
      }
      else {
          pager.find('.next_link').hide();
      }
      
      pager.data("curr",page);
      pager.children().removeClass("active");
      pager.children().eq(page+1).addClass("active");
  
  }
};


$(document).ready(function() {

});