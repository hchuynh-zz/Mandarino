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
          openrules: function(){
            $('#rules').removeClass("hidden").popup("show");
          },
          init: function(){
            $.fn.popup.defaults.transition = 'all 0.3s';
            $('#my_popup').popup();
            $('#rules').popup();
            $('#my_popup_close').click(function(){
              $('#my_popup').popup("hide");
            });
            $('#rules_close').click(function(){
              $('#rules').popup("hide");
            });
          }
        }
        
        var stats = {
          getGoal: function(){
            var goal = 0;
            var val = $("#stats_goal").val();
            if (val && val > 0) goal = val;
            return goal;
          },
          getToday: function(){
            var today = 0;
            var val = $("#stats_today").val();
            if (val && val > 0) today = val;
            return today;
          },
          getTotal: function(){
            var total = 0;
            var val = $("#stats_total").val();
            if (val && val > 0) total = val;
            return total;
          },
          getLeft: function(){

            var left = "penso che moriro'" ;
            var val1 = $("#stats_goal").val();
            var val2 = $("#stats_total").val();
            if (val1 && val2){
              if ( (val1 - val2) >0) left = "me ne mancano ancora "+ (val1 - val2);
            }else{
              left = "sono già oltre di "+ (val2 - val1)+" #mandarini";
            }
            
            return left;
          },

        }
        popup.init();


        $("#howmany").keypress(function(e){
            var theEvent = e || window.event;
            var key = theEvent.keyCode || theEvent.which;
            key = String.fromCharCode( key );
            var regex = /[0-9]|\./;
            if (key == 13) {
                $("#theForm").submit();
            }
            if( !regex.test(key) ) {
              if(theEvent.preventDefault) theEvent.preventDefault();
            }

        }).focus(function(){
          $(this).select();
        });

        $("#theForm").submit(function(e){
          e.preventDefault();

          $.ajax({
            type: "POST",
            url: "/more",
            data: $("#theForm").serialize(),
            success: function(data){
              $("#alert").html(data);
              $('#my_popup').removeClass("hidden").popup();
              console.log(data);
            },
            error: function(data){
              $("#alert").html(data)
              $('#my_popup').removeClass("hidden").popup();
              console.log(data);

            }
          });
          return false;
        });



        $('#postToWall').click(function() {
          FB.ui(
            {
              method : 'feed',
              //link   : $(this).attr('data-url')

              name: 'La Sfida dei Mandarini',
              link: 'https://apps.facebook.com/mandarino',
              picture: 'https://still-peak-5198.herokuapp.com/images/mandarino.jpg',
              description: 'Oggi ho mangiato '+stats.getToday()+' #mandarini e per arrivare a '+stats.getGoal()+' il 31 Dicembre, '+stats.getLeft()+'.'
            },
            function (response) {
              // If response is null the user canceled the dialog
              if (response != null) {
                logResponse(response);
              }
            }
          );
        });

        $('.apprequests').click(function() {
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


        $("#actionrules").click(function(){ popup.openrules();});

        $("#howmany").focus();
      });
      