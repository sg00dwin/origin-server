$(function(){jQuery.validator.addMethod("aws_account",function(a){return(/^[\d]{4}-[\d]{4}-[\d]{4}$/).test(a)},"Account numbers should be a 12-digit number separated by dashes. Ex: 1234-5678-9000");jQuery.validator.addMethod("alpha_numeric",function(a){return(/^[A-Za-z0-9]*$/).test(a)},"Only letters and numbers are allowed");$("#login-form form").validate({rules:{login:{required:true},password:{required:true}}});$("#new_web_user").validate({rules:{"web_user[email_address]":{required:true,email:true},"web_user[password]":{required:true,minlength:6},"web_user[password_confirmation]":{required:true,equalTo:"#web_user_password"}}});$("#new_access_express_request").validate({rules:{"access_express_request[terms_accepted]":"required"}});$("#new_access_flex_request").validate({rules:{"access_flex_request[terms_accepted]":"required"}});$("#new_express_domain").validate({rules:{"express_domain[namespace]":{required:true,alpha_numeric:true,maxlength:16},"express_domain[ssh]":{required:true,accept:".pub"},"express_domain[password]":{required:true,minlength:6}}});$("input").not("[type=hidden]").first().focus()});