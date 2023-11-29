    var config = {
        apiKey: "AIzaSyBZ24_L0FNRZeU1AMyFa254A4sN5FlDYYg",
        authDomain: "bible-art-wallpaper-hd.firebaseapp.com",
        databaseURL: "https://bible-art-wallpaper-hd.firebaseio.com",
        projectId: "bible-art-wallpaper-hd",
        storageBucket: "bible-art-wallpaper-hd.appspot.com",
        messagingSenderId: "803780061245",
        appId: "1:803780061245:web:a21ae89b53acb44f3c2254",
        measurementId: "G-R7W3C4X5RV"
    };

    if (!firebase.apps.length) {
        firebase.initializeApp(config);
        firebase.auth.Auth.Persistence.LOCAL; 
    }

    

    $("#btn-login").click(function(){
        $("#btn-login").prop('disabled',true);
        $("#btn-login").html('Please Wait....');
        $("#alertMessage").hide();   
        var email = $("#email").val();
        var password = $("#password").val(); 

        var result = firebase.auth().signInWithEmailAndPassword(email, password);
    
        result.catch(function(error){
            var errorCode = error.code; 
            var errorMessage = error.message; 
            $("#btn-login").prop('disabled',false);
            $("#btn-login").html('Login');
            $("#alertMessage").show(); 
            console          
        });

    });

    $("#alertMessage").hide();   

    $("#btn-logout").click(function(){
        firebase.auth().signOut();
    });    

    function switchView(view){
        $.get({
            url:view,
            cache: false,  
        }).then(function(data){
            $("#container").html(data);
        });
    }