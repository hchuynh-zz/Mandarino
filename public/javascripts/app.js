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

        $("#theForm").submit(function(e){
          e.preventDefault();

          $.ajax({
            type: "POST",
            url: "/more",
            data: $("#theForm").serialize(),
            success: function(data){
              $("#alert").html(data);
              $('#my_popup').removeClass("hidden").popup("show");
              console.log(data);
            },
            error: function(data){
              $("#alert").html(data)
              $('#my_popup').removeClass("hidden").popup("show");
              console.log(data);

            }
          });
          return false;
        });

        $("#howmany").keypress(function(evt){
              var e = evt || window.event;
              var key = e.keyCode || e.which;

              if (key == 13){
                $("#theForm").submit();
              }

              if (!e.shiftKey && !e.altKey && !e.ctrlKey &&
              // numbers   
              key >= 48 && key <= 57 ||
              // Numeric keypad
              key >= 96 && key <= 105 ||
              // Backspace and Tab and Enter
              key == 8 || key == 9 || key == 13 ||
              // Home and End
              key == 35 || key == 36 ||
              // left and right arrows
              key == 37 || key == 39 ||
              // Del and Ins
              key == 46 || key == 45) {
                  // input is VALID
              }
              else {
                  // input is INVALID
                  e.returnValue = false;
                  if (e.preventDefault) e.preventDefault();
              }
          }).focus(function(){
          $(this).select();
        });


        $('#postToWall').click(function() {
          FB.ui(
            {
              method : 'feed',
              //link   : $(this).attr('data-url')

              name: 'La Sfida dei Mandarini',
              link: 'https://apps.facebook.com/mandarino',
              picture: 'https://still-peak-5198.herokuapp.com/images/mandarino.jpg',
              description: 'Oggi ho mangiato '+stats.getToday()+' #mandarini, sono a quota '+stats.getTotal()+'!! Ad arrivare al 31 Dicembre, '+stats.getLeft()+'.'
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
      