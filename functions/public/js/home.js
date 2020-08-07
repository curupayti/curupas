$(document).ready(function () {

    let name = _user.name;
    let role_desc = _role.desc;

    let length = _role.roles.length;

    let modules = "";

    for (let i=0; i<length; i++) { 

        var id = _role.roles[i].id;
        var desc = _role.roles[i].desc;
        var html = _role.roles[i].html;
        var js = _role.roles[i].js;
        var css = _role.roles[i].css;      

        let item = '<a id="' + id + '" class="nav-link" href="javascript:void(0);" onclick="loadPage(\'' + id + '\', \'' + html + '\', \'' + js + '\', \'' + css + '\'); return false;">' + desc + '</a>';                 
        console.log(item, _role, _role.roles[i]);
        
        modules += item;

    }

    $('#welcome').html("Bienvenido " +name);
    $('#role').html(role_desc);
    $('#modules').html(modules);
    console.log(_role);
    
    if(_role.homepageData) {
        $("#homepage-data").html(_role.homepageData.html);
    }
    
    //# sourceURL=home.js   

});