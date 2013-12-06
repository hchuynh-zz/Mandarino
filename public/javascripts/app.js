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
          getGoal = function(){
            var goal = 0;
            var val = $("#stats_goal").value();
            if (val && val > 0) goal = val;
            return goal;
          },
          getToday = function(){
            var today = 0;
            var val = $("#stats_today").value();
            if (val && val > 0) today = val;
            return today;
          },
          getTotal = function(){
            var total = 0;
            var val = $("#stats_total").value();
            if (val && val > 0) total = val;
            return total;
          },
          getLeft = function(){

            var left = "penso che moriro'" ;
            var val1 = $("#stats_goal").value();
            var val2 = $("#stats_total").value();
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
            if( !regex.test(key) ) {
              if(theEvent.preventDefault) theEvent.preventDefault();
            }
        }).focus(function(){
          $(this).select();
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

        $("#actionrules").click(function(){ popup.openrules();});

        $("#howmany").focus();
      });
      