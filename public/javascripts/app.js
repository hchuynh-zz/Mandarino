      function logResponse(response) {
        if (console && console.log) {
          console.log('The response was', response);
        }
      }

      $( document ).ready(function(){

        $('#postToWall').click(function() {
          FB.ui(
            {
              method : 'feed',
              link   : $(this).attr('data-url')
            },
            function (response) {
              // If response is null the user canceled the dialog
              if (response != null) {
                logResponse(response);
              }
            }
          );
        });

        $('#sendRequest').click(function() {
          FB.ui(
            {
              method  : 'apprequests',
              message : $(this).attr('data-message')
            },
            function (response) {
              // If response is null the user canceled the dialog
              if (response != null) {
                logResponse(response);
              }
            }
          );
        });

        $("#howmany").keypress(function(e){
            var theEvent = e || window.event;
            var key = theEvent.keyCode || theEvent.which;
            key = String.fromCharCode( key );
            var regex = /[0-9]|\./;
            if( !regex.test(key) ) {
              theEvent.returnValue = false;
              if(theEvent.preventDefault) theEvent.preventDefault();
            }
        });

        $("#mandarinosubmit").submit(function(e){
          e.preventDefault();

          $.ajax({
            type: "POST",
            url: "/register",
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
        });

      });
      