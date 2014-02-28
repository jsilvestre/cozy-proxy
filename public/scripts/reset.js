// Generated by CoffeeScript 1.4.0
(function() {

  $(function() {
    var button, errorAlert, passwordInput, submitPassword, successAlert;
    button = $('#submit-btn');
    passwordInput = $('#password-input');
    errorAlert = $('.alert-error');
    successAlert = $('.alert-success');
    submitPassword = function() {
      button.spin('small');
      return client.post("/password/reset/" + key, {
        password: passwordInput.val()
      }, {
        success: function() {
          button.spin();
          button.html('change password');
          errorAlert.fadeOut();
          successAlert.fadeIn();
          successAlert.html("Password reset succeeded");
          return wait(1000, function() {
            return $("#content").fadeOut(function() {
              return window.location = "/login";
            });
          });
        },
        error: function(err) {
          var msg;
          console.log("got error");
          console.debug(err);
          console.debug(err.responseText);
          button.spin();
          button.html('change password');
          successAlert.fadeOut();
          msg = JSON.parse(err.responseText).error;
          errorAlert.html(msg);
          return errorAlert.fadeIn();
        }
      });
    };
    passwordInput.keyup(function(event) {
      if (event.which === 13) {
        return submitPassword();
      }
    });
    button.click(submitPassword);
    return passwordInput.focus();
  });

}).call(this);
