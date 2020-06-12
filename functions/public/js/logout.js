$(document).ready(function () {
  let name = _user.name;
  let role_desc = _role.desc;

  //$('#welcome').html("Bienvenido " +name);
  //$('#role').html(role_desc);

  //# sourceURL=logout.js
  $("#btn-logout").click(function (e) {
    e.preventDefault();
    firebase
      .auth()
      .signOut()
      .then(function () {
        // Sign-out successful.
        window.location.href = "index.html";
      })
      .catch(function (error) {
        // An error happened.
      });
  });
});
