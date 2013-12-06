      function logResponse(response) {
        if (console && console.log) {
          console.log('The response was', response);
        }
      }

      $( document ).ready(function(){

        var popup = {
          open: function(title,text){
            $("#alert").html("<h4>"+title+"</h4>"+"<p>"+text+"</p>");
            $('#my_popup').removeClass("hidden").popup("show");
          },
          init: function(){
            $('#my_popup').popup();
            $('#my_popup_closing').click(function(){
              $('#my_popup').toggle();
            })
          }
        }
        
        popup.init();


        $("#howmany").keypress(function(e){
            var theEvent = e || window.event;
            var key = theEvent.keyCode || theEvent.which;
            key = String.fromCharCode( key );
            var regex = /[0-9]|\./;
            if( !regex.test(key) ) {
              if(theEvent.preventDefault) theEvent.preventDefault();
            }
        });

        $("#theForm").submit(function(e){
          e.preventDefault();
          popup.open("Yeay", "Test");

          return false;
/*
          $.ajax({
            type: "POST",
            url: "/more",
            data: $("#mandarinosubmit").serialize(),
            success: function(){
              $("#alert").html("Successfully registered");
              $('#my_popup').popup();
            },
            error: function(){
              $("#message").html("Not Successful")
              $('#my_popup').popup();
            }
          });
*/
        });


      });
      