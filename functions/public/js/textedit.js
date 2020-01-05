$(document).ready(function () {

  
  var userId = _user.userId;

  var firepad = null, userList = null, codeMirror = null;

  //function joinFirepadForHash() {

    if (firepad) {
      // Clean up.
      firepad.dispose();
      userList.dispose();
      $('.CodeMirror').remove();
    }

    //var id = window.location.hash.replace(/#/g, '') || randomString(10);
    var url = window.location.toString().replace(/#.*/, '') + '#' + id;
    //var firepadRef = new Firebase('https://firepad.firebaseio.com/demo').child(id);

    var id =  _user.userId;
    var firepadRef = database.ref(id);

    //var id = window.location.hash.replace(/#/g, '') || randomString(10);
    var url = window.location.toString().replace(/#.*/, '') + '#' + id;
    var firepadRef = new Firebase('https://firepad.firebaseio.com/demo').child(id);

    var id = window.location.hash.replace(/#/g, '') || randomString(10);
  //var url = window.location.toString().replace(/#.*/, '') + '#' + id;
  var firepadRef = new Firebase(firebaseConfig.databaseURL).child(id);

  var userId = firepadRef.push().name(); // Just a random ID.
  codeMirror = CodeMirror(document.getElementById('firepad'), { lineWrapping: true });
  firepad = Firepad.fromCodeMirror(firepadRef, codeMirror,
      { richTextToolbar: true, richTextShortcuts: true, userId: userId});
  userList = FirepadUserList.fromDiv(firepadRef.child('users'),
      document.getElementById('firepad-userlist'), userId);

    firepad.on('ready', function() {
      if (firepad.isHistoryEmpty()) {
        firepad.setText('Welcome to your own private pad!\n\nShare the URL below and collaborate with your friends.');
      }

      ensurePadInList(id);
      buildPadList();
    });


    codeMirror.focus();

    window.location = url;
    $('#url').val(url);
    $("#url").on('click', function(e) {
      $(this).focus().select();
      e.preventDefault();
      return false;
    });

    setTimeout(function() {
      $(window).on('hashchange', joinFirepadForHash);
    }, 0);

  //}

  function padListEnabled() {
    return (typeof localStorage !== 'undefined' && typeof JSON !== 'undefined' && localStorage.setItem &&
        localStorage.getItem && JSON.parse && JSON.stringify);
  }

  function ensurePadInList(id) {
    if (!padListEnabled()) { return; }
    var list = JSON.parse(localStorage.getItem('demo-pad-list') || "{ }");
    if (!(id in list)) {
      var now = new Date();
      var year = now.getFullYear(), month = now.getMonth() + 1, day = now.getDate();
      var hours = now.getHours(), minutes = now.getMinutes();
      if (hours < 10) { hours = '0' + hours; }
      if (minutes < 10) { minutes = '0' + minutes; }

      list[id] = [year, month, day].join('/') + ' ' + hours + ':' + minutes;

      localStorage.setItem('demo-pad-list', JSON.stringify(list));
      buildPadList();
    }
  }

  function buildPadList() {
    if (!padListEnabled()) { return; }
    $('#my-pads-list').empty();

    var list = JSON.parse(localStorage.getItem('demo-pad-list') || '{ }');
    for(var id in list) {
      $('#my-pads-list').append(
          $('<div></div>').addClass('my-pads-item').append(
              makePadLink(id, list[id])
      ));
    }
  }

  function makePadLink(id, name) {
    return $('<a></a>')
        .text(name)
        .on('click', function() {
          window.location = window.location.toString().replace(/#.*/, '') + '#' + id;
          $('#my-pads-list').hide();
          return false;
    });
  }

  function randomString(length) {
    var text = "";
    var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

    for(var i=0; i < length; i++)
      text += possible.charAt(Math.floor(Math.random() * possible.length));

    return text;
  }

  /*$(window).on('ready', function() {
    joinFirepadForHash();
    setTimeout(function() {
      $(window).on('hashchange', joinFirepadForHash);
    }, 0);
  });*/

  function displayPads() {
    $('#my-pads-list').toggle();
  }

   


  function getFirepadById (firepadId) {

      var getFirePadFromRef = functions.httpsCallable('getFirePadFromRef');
      getFirePadFromRef({"refId": firepadId}).then(function(result) {
      
      var sanitizedMessage = result.data.text;

      console.log(sanitizedMessage);
      
    }).catch(function(error) {
      // Getting the Error details.
      var code = error.code;
      var message = error.message;
      var details = error.details;
      // ...
    });

  }

    //# sourceURL=textedit.js   

});