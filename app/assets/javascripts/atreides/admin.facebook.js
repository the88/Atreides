$(function(){
  if ( $(".authenticate-facebook").length ) {

    var $permissions = ["read_insights","manage_pages"]

    function status(msg,angry){
      $("#status").css({
        "padding": "10px 15px",
        "width": "69%"
      });

      if ( angry ){
        $("#status").css({
          "background":"#ffaaaa",
          border: "1px solid #ff6666"
        })
      } else {
        $("#status").css({
          "background":"#aaffaa",
          border: "1px solid #44dd44"
        })
      }
      $("#status").text(msg)
    }

    $(".deauthenticate-facebook").on("click", function(e){
      e.preventDefault();
      FB.logout(function(response){
        $(".access-container").hide();
        $(".login-container").show();
      })
    })


    function checkPermissions(neededPerms, f, params, done){
      console.log("checking permissions")
      FB.api('/me/permissions', function(reponde) {
        var permsArray = reponde.data[0];
        var reUpPerms = new Array();
        console.log(permsArray)
        for(i in neededPerms){
          if ( permsArray[neededPerms[i]] == null && typeof(neededPerms[i]) == "string") {
            reUpPerms.push(neededPerms[i]);
          }
        }
        if (reUpPerms.length > 0) {
          FB.login(function(response){
            if (done){
              status("Please accept all permissions to continue.", true)
              return false;
            }
            // Recheck, just in case the user didn't accept something.
            checkPermissions(neededPerms, f, params, true);
          }, {scope: neededPerms.join(",")});
        } else {
          f.apply(this, params)
        }
      });
    }

    function dealWithResponse(response, checked){

      console.log(response)

      if ( response.status == "connected" ) {
        status("Connected to facebook")

        // Check for permissions
        if (!checked){
          checkPermissions($permissions, dealWithResponse, [response, true])
        } else {
          var authResponse = response.authResponse,
              accessToken = authResponse.accessToken,
              userId = authResponse.userID,
              expiry = authResponse.expiresIn;

          // First, get extended token.
          $.post("/admin/facebook",
            {
              access_token: accessToken,
              user_id: userId,
              authenticity_token: $.token,
              expiry: expiry
            }
          ).success(function(){
            status("Token successfully stored.")
            setTimeout(function(){window.location.href = "/admin/"}, 500)
          }).error(function(){
            status("There was a problem updating the page token. Please ensure that you are an admin on Facebook page you are trying to collect analytics for.", true)
          })
        }
      } else if (response.status == "not_authorized") {
        status("Please accept the terms in the facebook dialog", true)
      } else {
        status("There was an error authorizing: " + response.status, true)
      }
    }


    $("a.authenticate-facebook").on("click", function(e){
      e.preventDefault();
      FB.getLoginStatus(function(response){
        if ( response.status == "connected" ){
          dealWithResponse(response)
        } else {
          $("p.login-container").show();
        }
      })
    })

    $("a.fb-login").on("click", function(e){
      e.preventDefault();
      FB.login(function(response){
        if (response.status == "connected"){
          $(".access-container").show();
          $(".login-container").hide();
        } else {
          // nothing
        }
      })
    })


    setTimeout(function(){
      // Choose which link to show.
      FB.getLoginStatus(function(response){
        if ( response.status != "unknown" ) {
          $(".access-container").show();
        } else if ( response.status == "unknown" ) {
          $(".login-container").show();
        }
      })
    }, 500)


  }
});