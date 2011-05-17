from selenium import selenium
import unittest, time, re
#import HTMLTestRunner
import sys
import string

password="redhat"
browser="*firefox"
host="192.168.122.1"
url="https://stg.openshift.redhat.com"
port=5557
#browser="googlechrome"
#browser="firefox"
#browser="*iexplore"
#browser="*konqueror"
confirm_url="https://stg.openshift.redhat.com/app/email_confirm?key=w9btgjDswstFYKgIPjo6M0MXtMDXjWtPkJctiftX&emailAddress=xtian%2Bc216%40redhat.com"
pathstart=str.index(confirm_url,"app")
baseconfirm_url=confirm_url[:pathstart]
path=confirm_url[pathstart-1:]
i=str.index(path,"=")
j=str.index(path,"&") 
k=str.rindex(path,"=")
m=str.index(path,"?")
key=path[i+1:j]
email=path[k+1:]
invalidemail_confirm_url= str.replace(path,email,"")
invalidkey_confirm_url=str.replace(path,key,"")
noemail_confirm_url=path[:j-1]
nokey_confirm_url=path[:m+1]+path[j+1:]

toregister_userlist=['xtian+cc0@redhat.com']
new_userlist=['xtian+c220@redhat.com','xtian+c219@redhat.com','xtian+c218@redhat.com','xtian+c217@redhat.com','xtian+c2116@redhat.com']
old_userlist=['xtian+1@redhat.com']


class b_Register(unittest.TestCase):
    def setUp(self):
        self.verificationErrors = []
        self.selenium = selenium(host, port, browser, url)
        self.selenium.start()
        
    
    def test_register__nocaptcha(self):
        sel = self.selenium
        sel.open("/app/user/new")
        for i in range(60):
            try:
                if sel.is_element_present("web_user_email_address"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("web_user_email_address"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.type("web_user_email_address", toregister_userlist[0])
        sel.type("web_user_password",password)
        sel.type("web_user_password_confirmation",password)
        sel.click("web_user_submit")
  #      sel.wait_for_page_to_load("60000")
        for i in range(60):
            try:
                if sel.is_text_present("Captcha text didn't match"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_text_present("Captcha text didn't match"))
        except AssertionError, e: self.verificationErrors.append(str(e))
    

    def test_mis_match_pwd(self):
        sel = self.selenium
        sel.open("/app/user/new")
     #       sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_element_present("web_user_email_address"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("web_user_email_address"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.type("web_user_email_address", toregister_userlist[0])
        sel.type("web_user_password",password)
        sel.type("web_user_password_confirmation", "1234567")
#        sel.type("recaptcha_response_field", "unbelief rsalibra")
        sel.click("web_user_submit")
  #      sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_text_present("Please enter the same value again."): break
            except: pass
            time.sleep(1)
        else: self.fail("time out,enter the same value")
        try: self.failUnless(sel.is_text_present("Please enter the same value again."))
        except AssertionError, e: self.verificationErrors.append(str(e)) 

    def test_invalid_email(self):
        sel = self.selenium
        sel.open("/app/user/new")
        for i in range(60):
            try:
                if sel.is_element_present("web_user_email_address"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("web_user_email_address"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.type("web_user_email_address", "xtian")
 #       sel.type("web_user_password",password)
  #      sel.type("web_user_password_confirmation",password)
#        sel.type("recaptcha_response_field", "darta furniture")
        sel.click("web_user_submit")
      #  sel.wait_for_page_to_load("30000")
        for i in range(60):
            try: 
                if sel.is_text_present("Please enter a valid email address."): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_text_present("Please enter a valid email address."))
        except AssertionError, e: self.verificationErrors.append(str(e))   

    def test_no_email(self):
        sel = self.selenium
        sel.open("/app/user/new")
        for i in range(60):
            try:
                if sel.is_element_present("web_user_email_address"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("web_user_email_address"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.type("web_user_password",password)
#        sel.type("web_user_password_confirmation",password)
#        sel.type("recaptcha_response_field", "seemingly eandaysi")
        sel.click("web_user_submit")
  #      sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_text_present("This field is required."): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_text_present("This field is required."))
        except AssertionError, e: self.verificationErrors.append(str(e))

    def test_no_pwd(self):
        sel = self.selenium
        sel.open("/app/user/new")       
  #      sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_element_present("web_user_email_address"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("web_user_email_address"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.type("web_user_email_address", toregister_userlist[0])
        sel.type("web_user_password_confirmation",password)
 #       sel.type("recaptcha_response_field", "osionsys cause")
        sel.click("web_user_submit")
 #       sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_text_present("This field is required."): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_text_present("This field is required."))
        except AssertionError, e: self.verificationErrors.append(str(e))
  
    def test_invalid_pwd(self):
        sel = self.selenium
        sel.open("/app/user/new")
        for i in range(60):
            try:
                if sel.is_element_present("web_user_email_address"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("web_user_email_address"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.type("web_user_email_address", toregister_userlist[0])
        sel.type("web_user_password", "12345")
        sel.type("web_user_password_confirmation", "12345")
 #       sel.type("recaptcha_response_field", "weivie spond")
        sel.click("web_user_submit")
    #    sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_text_present("Please enter at least 6"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_text_present("Please enter at least 6"))
        except AssertionError, e: self.verificationErrors.append(str(e))
    '''   
    def test_normal(self):
        sel = self.selenium
        sel.open("/app/user/new")
 #       sel.wait_for_page_to_load("60000")
        for i in range(60):
            try:
                if sel.is_element_present("web_user_email_address"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("web_user_email_address"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.type("web_user_email_address", toregister_userlist[0])
        sel.type("web_user_password",password)
        sel.type("web_user_password_confirmation",password)
#        sel.type("recaptcha_response_field", "LocaterMap eirorso")
        sel.click("web_user_submit")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_text_present("Check your inbox for an email with a validation link"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_text_present("Check your inbox for an email with a validation link"))
        except AssertionError, e: self.verificationErrors.append(str(e))
    
    def test_email_regisetered(self):
        sel = self.selenium
        sel.open("/app/user/new")
        for i in range(60):
            try:
                if sel.is_element_present("web_user_email_address"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("web_user_email_address"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.type("web_user_email_address", "xtian+1@redhat.com")
        sel.type("web_user_password", "123456")
        sel.type("web_user_password_confirmation", "123456")
 #       sel.type("recaptcha_response_field", "ouraitt action")
        sel.click("web_user_submit")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_text_present("A user with the same email is already registered"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_text_present("A user with the same email is already registered"))
        except AssertionError, e: self.verificationErrors.append(str(e))
    '''
    
    def test_register_from_restricted_contry(self):
        sel = self.selenium
        sel.open("/app/user/new")
        for i in range(60):
            try:
                if sel.is_text_present("Login"): break
            except: pass
            time.sleep(1) 
        else: self.fail("time out")
        try: self.failUnless(sel.is_text_present("Login"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if "" == sel.get_text("web_user_email_address"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.assertEqual("", sel.get_value("web_user_email_address"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.type("web_user_email_address", "xtian+1@redhat.kp")
        sel.type("web_user_password", "123456")
        sel.type("web_user_password_confirmation", "123456")
        sel.click("web_user_submit")
    #    sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_text_present("We can not accept emails from the following"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_text_present("We can not accept emails from the following"))
        except AssertionError, e: self.verificationErrors.append(str(e))

  
    def tearDown(self):
        self.selenium.stop()
        self.assertEqual([], self.verificationErrors)




class c_Confirm_Email(unittest.TestCase):
    def setUp(self):
        self.verificationErrors = []
        self.selenium = selenium(host, port, browser, url)
        self.selenium.start()

    def test_b_def_grant_when_confirm(self):
        sel = self.selenium
        sel.open(path)
        for i in range(60):
            try:
                if sel.is_element_present("login_input"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("login_input"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.type("login_input", new_userlist[4])
        sel.type("pwd_input",password)
        sel.click("//input[@value='Login']")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_element_present("link=OpenShift Legal Terms and Conditions"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=OpenShift Legal Terms and Conditions"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("term_submit")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_element_present("link=Logout"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Logout"))
        except AssertionError, e: self.verificationErrors.append(str(e))

        for i in range(60):
            try:
                if "OpenShift by Red Hat | Get Started with Express" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out,not direct to get started page")
        sel.click("link=Logout")
        sel.wait_for_page_to_load("30000")
   
    
    def test_c_invalid_email(self):
        sel = self.selenium
        sel.open(invalidemail_confirm_url)
        for i in range(60):
            try:
                if sel.is_text_present("Email confirmation failed"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out,Email confirmation failed not found when invalid email")
        try: self.failUnless(sel.is_text_present("Email confirmation failed"))
        except AssertionError, e: self.verificationErrors.append(str(e))
    
    def test_a_invalid_key(self):
        sel = self.selenium
        sel.open(invalidkey_confirm_url)
        for i in range(60):
            try:
                if sel.is_text_present("Email confirmation failed"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out,Email confirmation failed not found when invalid key ")
        try: self.failUnless(sel.is_text_present("Email confirmation failed"))
        except AssertionError, e: self.verificationErrors.append(str(e))
    
    def test_no_key(self):
        sel = self.selenium
        sel.open(nokey_confirm_url)
        for i in range(60):
            try:
                if sel.is_text_present("The confirmation link used is missing the key parameter."): break
            except: pass
            time.sleep(1)
        else: self.fail("time out,not check well without key")
        try: self.failUnless(sel.is_text_present("The confirmation link used is missing the key parameter."))
        except AssertionError, e: self.verificationErrors.append(str(e))

    def test_no_email(self):
        sel = self.selenium
        sel.open(noemail_confirm_url)
        for i in range(60):
            try:
                if sel.is_text_present("The confirmation link used is missing the emailAddress parameter."): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_text_present("The confirmation link used is missing the emailAddress parameter."))
        except AssertionError, e: self.verificationErrors.append(str(e))    


    def tearDown(self):
        self.selenium.stop()
        self.assertEqual([], self.verificationErrors)


class d_TermsAccept(unittest.TestCase):
    def setUp(self):
        self.verificationErrors = []
        self.selenium = selenium(host, port, browser, url)
        self.selenium.start()
    
    def test_a_first_login_accept_terms(self):
        sel = self.selenium
        sel.open("/app/login")
        for i in range(60):
            try:
                if sel.is_element_present("link=Login"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Login"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("login_input"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("login_input"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.type("login_input", new_userlist[0])
        sel.type("pwd_input",password)
        sel.click("//input[@value='Login']")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_element_present("link=OpenShift Legal Terms and Conditions"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=OpenShift Legal Terms and Conditions"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("term_submit")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_element_present("link=Logout"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Logout"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("link=Logout")
        sel.wait_for_page_to_load("30000")

    def test_b_not_accept_but_visit_other_page(self):
        sel = self.selenium
        sel.open("/app/login")
        for i in range(60):
            try:
                if sel.is_element_present("link=Login"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Login"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("login_input"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("login_input"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.type("login_input", new_userlist[1])
        sel.type("pwd_input",password)
        sel.click("//input[@value='Login']")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_element_present("link=OpenShift Legal Terms and Conditions"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=OpenShift Legal Terms and Conditions"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.open("/app/express")
        for i in range(60):
            try:
                if sel.is_element_present("link=OpenShift Legal Terms and Conditions"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=OpenShift Legal Terms and Conditions"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("term_submit")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_element_present("link=Logout"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Logout"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("link=Logout")
        sel.wait_for_page_to_load("30000")
    
    '''
    def test_c_first_request_access_accept_terms(self):
        sel = self.selenium
        sel.open("/app/access/express/request")
        for i in range(60):
            try:
                if sel.is_text_present("You'll need to login / register before asking for access"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_text_present("You'll need to login / register before asking for access"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.type("login_input", new_userlist[1])
        sel.type("pwd_input",password)
        sel.click("//input[@value='Login']")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_element_present("link=OpenShift Site Terms"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=OpenShift Site Terms"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("access_express_request_submit")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_text_present("you have been granted access"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_text_present("you have been granted access"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("link=Get started with express"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Get started with express"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("link=Logout")
        sel.wait_for_page_to_load("30000")
    '''    
    
    def tearDown(self):
        self.selenium.stop()
        self.assertEqual([], self.verificationErrors)





# Login test
class e_Login(unittest.TestCase):
    def setUp(self):
        self.verificationErrors = []
        self.selenium = selenium(host,port, browser, url)
        self.selenium.start()
    
    def test_access_without_login(self):
        sel = self.selenium
        sel.set_timeout("")
        sel.open("/app/login")
        for i in range(60):
            try:
                if sel.is_element_present("link=Login"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Login"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("login_input"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("login_input"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("pwd_input"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("pwd_input"))
        except AssertionError, e: self.verificationErrors.append(str(e))


    def test_login_with_olduser_normal(self):
        sel = self.selenium
        sel.set_timeout("")
        sel.open("/app/login")
        for i in range(60):
            try:
                if sel.is_element_present("link=Login"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Login"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("login_input"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("login_input"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("pwd_input"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("pwd_input"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.set_timeout("")
        sel.type("login_input", old_userlist[0])
        sel.type("pwd_input", "123456")
        sel.click("//input[@value='Login']")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "OpenShift by Red Hat" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        for i in range(60):
            try:
                if sel.is_element_present("link=Logout"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Logout"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("link=Logout")
        sel.wait_for_page_to_load("30000")

    def test_login_session_exist(self):
        sel = self.selenium
        sel.open("/app/login/")
        for i in range(60):
            try:
                if sel.is_element_present("link=Login"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Login"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.type("login_input", old_userlist[0])
        sel.type("pwd_input", "123456")
        sel.click("//input[@value='Login']")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_element_present("link=Logout"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Logout"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.open("/app/login")
        for i in range(60):
            try:
                if sel.is_text_present("Logout"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_text_present("Logout"))
        except AssertionError, e: self.verificationErrors.append(str(e))
    
    def test_login_logout_back(self):
        sel = self.selenium
        sel.open("/app/login")
        for i in range(60):
            try:
                if sel.is_element_present("link=Login"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Login"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.type("login_input", old_userlist[0])
        sel.type("pwd_input", "123456")
        sel.click("//input[@value='Login']")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_element_present("link=Logout"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Logout"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("link=Logout")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_element_present("link=Login"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Login"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.go_back()
        sel.refresh()
        for i in range(60):
            try:
                if sel.is_element_present("link=Login"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Login"))
        except AssertionError, e: self.verificationErrors.append(str(e))
    

       
    def test_login_invalid_account(self):
        sel = self.selenium
        sel.set_timeout("")
        sel.open("/app/login/")
        for i in range(60):
            try:
                if sel.is_element_present("link=Login"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("login_input"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.type("login_input", "xtian")
        sel.type("pwd_input",password)
        sel.click("//input[@value='Login']")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_text_present("Invalid username or password"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_text_present("Invalid username or password"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_element_present("link=Login"))
        except AssertionError, e: self.verificationErrors.append(str(e))
       
    
    def test_login_invaid_pwd(self):
        sel = self.selenium
        sel.set_timeout("")
        sel.open("/app/login/")
        for i in range(60):
            try:
                if sel.is_element_present("link=Login"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Login"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_element_present("login_input"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.type("login_input", old_userlist[0])
        sel.type("pwd_input", "123")
        sel.click("//input[@value='Login']")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_text_present("Invalid username or password"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_text_present("Invalid username or password"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_text_present("Login"))
        except AssertionError, e: self.verificationErrors.append(str(e))
    
    
    def test_login_sql_bypass(self):
        sel = self.selenium
        sel.set_timeout("")
        sel.open("/app/login")
        for i in range(60):
            try:
                if sel.is_element_present("link=Login"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_text_present("Login"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.type("login_input", "xtian+0@redhat.com OR 1'='1  \"")
        sel.type("pwd_input", "1234567")
        sel.click("//input[@value='Login']")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_text_present("Invalid username or password"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        for i in range(60):
            try:
                if sel.is_text_present("Invalid username or password"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_text_present("Invalid username or password"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_element_present("link=Login"))
        except AssertionError, e: self.verificationErrors.append(str(e))

    def test_login_viaRHN(self):
        sel = self.selenium
        sel.set_timeout("")
        sel.open("/app/login")
        for i in range(60):
            try:
                if sel.is_element_present("link=Login"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Login"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("login_input"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("login_input"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("pwd_input"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("pwd_input"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.set_timeout("")
        sel.type("login_input", "qa@redhat.com")
        sel.type("pwd_input", "redhatqa")
        sel.click("//input[@value='Login']")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_element_present("link=Logout"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Logout"))
        except AssertionError, e: self.verificationErrors.append(str(e))     

    def tearDown(self):
        self.selenium.stop()
        self.assertEqual([], self.verificationErrors)   


'''
class RequestAccess(unittest.TestCase):
    def setUp(self):
        self.verificationErrors = []
        self.selenium = selenium(host, port, browser, url)
        self.selenium.start()
    
    def test_a_first_request_access(self):
        sel = self.selenium
        sel.open("/app/access/express/request")
        for i in range(60):
            try:
                if sel.is_element_present("link=exact:Lost your password?"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=exact:Lost your password?"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("//div[@id='login-form']/p"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("//div[@id='login-form']/p"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_text_present("You'll need to login / register before asking for access"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_text_present("You'll need to login / register before asking for access"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("link=Click here to register"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Click here to register"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("login_input"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("login_input"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("link=Login"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("login"))
        except AssertionError, e: self.verificationErrors.append(str(e))
    
    def test_b_request_access_express(self):
        sel = self.selenium
        sel.open("/app/access/express/request")
        for i in range(60):
            try:
                if sel.is_element_present("link=Login"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Login"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.type("login_input",nogrant_userlist[0])
        sel.type("pwd_input",password)
        sel.click("//input[@value='Login']")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_element_present("link=Logout"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Logout"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("link=OpenShift Site Terms"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=OpenShift Site Terms"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("access_express_request_submit")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_text_present("you have been granted access"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_text_present("you have been granted access"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("link=Logout")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_element_present("link=Login"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Login"))
        except AssertionError, e: self.verificationErrors.append(str(e))
    
    

    
    def tearDown(self):
        self.selenium.stop()
        self.assertEqual([], self.verificationErrors)
'''

class a_Home(unittest.TestCase):
    def setUp(self):
        self.verificationErrors = []
        self.selenium = selenium(host,port, browser,url)
        self.selenium.start()

    def test_home_navigation_bar(self):
        sel = self.selenium
        sel.open("/app")
        for i in range(60):
            try:
                if "OpenShift by Red Hat" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("//div[@id='nav']/h5[1]")
        sel.click("//div[@id='nav']/h5[1]")
        for i in range(60):
            try:
                if sel.is_element_present("link=Express"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        for i in range(60):
            try:
                if sel.is_element_present("link=Flex"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        for i in range(60):
            try:
                if sel.is_element_present("link=Power"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("link=Express")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "OpenShift by Red Hat | Express" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.go_back()
        sel.click("link=Flex")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "OpenShift by Red Hat | Flex" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.go_back()
        sel.click("link=Power")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "OpenShift by Red Hat | Power" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.go_back()
        sel.click("//div[@id='nav']/h5[2]")
        for i in range(60):
            try:
                if sel.is_element_present("link=Forums"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Blog"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_element_present("link=Partners"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("link=Forums")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "Forums | Red Hat Openshift Forum" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.go_back()
        for i in range(60):
            try:
                if "OpenShift by Red Hat" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("//div[@id='nav']/h5[2]")
        sel.click("link=Blog")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "Blogs | Red Hat Openshift Forum" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("link=Partners")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "OpenShift by Red Hat | Meet Our Partners" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("//div[@id='nav']/h5[2]")
        sel.click("//div[@id='nav']/h5[3]")
        try: self.failUnless(sel.is_element_present("link=KB"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_element_present("link=Docs"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_element_present("link=Videos"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_element_present("link=FAQ"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("link=KB")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "Knowledge Base | Red Hat Openshift Forum" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("//div[@id='nav']/h5[3]")
        sel.click("link=Docs")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "Documents | Red Hat Openshift Forum" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("//div[@id='nav']/h5[3]")
        sel.click("link=Videos")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "Videos | Red Hat Openshift Forum" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("//div[@id='nav']/h5[3]")
        sel.click("link=FAQ")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "Frequently Asked Questions | Red Hat Openshift Forum" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("//div[@id='logo']/a/img")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "OpenShift by Red Hat" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")

    def test_check_home_links(self):
        sel = self.selenium
        sel.open("/app/")
        try: self.failUnless(sel.is_element_present("link=Try it now!"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("link=Try it now!")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "Register for access to Express" == sel.get_text("//div[@id='registration']/h3"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.go_back()
        for i in range(60):
            try:
                if sel.is_element_present("//a[contains(text(),'Learn More >')]"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("//a[contains(text(),'Learn More >')]"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("link=Learn More >")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "OpenShift by Red Hat | Express" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        for i in range(60):
            try:
                if sel.is_element_present("//img[@alt='OpenShift by Red Hat Cloud']"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("//img[@alt='OpenShift by Red Hat Cloud']"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("//img[@alt='OpenShift by Red Hat Cloud']")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "OpenShift by Red Hat" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        for i in range(60):
            try:
                if sel.is_element_present("//div[@id='cutting_edge']/a"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("//div[@id='cutting_edge']/a"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("//div[@id='cutting_edge']/a")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "OpenShift by Red Hat | Flex" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.go_back()
        for i in range(60):
            try:
                if "OpenShift by Red Hat" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
    
    
    def test_check_footer(self):
        sel = self.selenium
        sel.open("/app/")
        for i in range(60):
            try:
                if "OpenShift by Red Hat" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        for i in range(60):
            try:
                if sel.is_element_present("link=Legal"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Legal"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("link=Legal")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "OpenShift by Red Hat | Terms and Conditions" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.go_back()
        for i in range(60):
            try:
                if "OpenShift by Red Hat" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        for i in range(60):
            try:
                if sel.is_element_present("link=Privacy Policy"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Privacy Policy"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("link=Privacy Policy")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "OpenShift by Red Hat | OpenShift Privacy Statement" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.go_back()
        for i in range(60):
            try:
                if sel.is_element_present("link=Contact Us"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")

    def test_check_home_content(self):
        sel = self.selenium
        sel.open("/app/")
        for i in range(60):
            try:
                if sel.is_element_present("//img[@alt='OpenShift by Red Hat Cloud']"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("//img[@alt='OpenShift by Red Hat Cloud']"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if "Free, leading-edge cloud services that enable developers to deploy applications written in multiple frameworks and languages across clouds." == sel.get_text("//div[@id='plug']/p"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.assertEqual("Free, leading-edge cloud services that enable developers to deploy applications written in multiple frameworks and languages across clouds.", sel.get_text("//div[@id='plug']/p"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("link=1")
        sel.click("link=2")
        try: self.failUnless(sel.is_text_present("OpenShift is for Developers"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("//div[@id='for_developers']/p")
        try: self.failUnless(sel.is_text_present("OpenShift is for developers who love to build on open source, but don't need the hassle of building and maintaining infrastructure."))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_text_present("OpenShift is Cutting-Edge"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("//div[@id='cutting_edge']/p")
        try: self.failUnless(sel.is_text_present("Supports all the coolest languages and frameworks, plus PaaS automation features like auto-scaling and performance monitoring."))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_element_present("front_image"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("//img[@alt='Gearshift_express_dev_preview']"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.mouse_over("//img[@alt='Gearshift_express_dev_preview']")
        try: self.assertEqual("Free and easy cloud deployments", sel.get_text("//div[@id='app_promos']/div[1]/div/ul/li[1]"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.assertEqual("PHP, Python, Ruby", sel.get_text("//div[@id='app_promos']/div[1]/div/ul/li[2]"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.assertEqual("Git push and leave the rest to us!", sel.get_text("//div[@id='app_promos']/div[1]/div/ul/li[3]"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("//img[@alt='Gearshift_flex_dev_preview']"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.mouse_over("//img[@alt='Gearshift_flex_dev_preview']")
        try: self.failUnless(sel.is_text_present("Auto-scale new and existing apps in the cloud"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_text_present("PHP, Java EE, MySQL, MongoDB, Memcache, DFS"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_text_present("Full control over configuration & Built-in monitoring"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("//img[@alt='Gearshift_power_coming_soon']"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.mouse_over("//img[@alt='Gearshift_power_coming_soon']")
        try: self.failUnless(sel.is_text_present("Complete control over cloud deployments"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_text_present("Custom topologies, root access, multi-tier dependencies"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_text_present("Turn any application into a cloud deployment template"))
        except AssertionError, e: self.verificationErrors.append(str(e))
    
    
    def tearDown(self):
        self.selenium.stop()
        self.assertEqual([], self.verificationErrors)

class f_Express(unittest.TestCase):
    def setUp(self):
        self.verificationErrors = []
        self.selenium = selenium(host, port, browser, url)
        self.selenium.start()
    
    def test_check_express_links(self):
        sel = self.selenium
        sel.open("/app/express")
        for i in range(60):
            try:
                if "Try it now!" == sel.get_text("//div[@id='banner']/a"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.assertEqual("Try it now!", sel.get_text("//div[@id='banner']/a"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("//div[@id='banner']/a")
        sel.wait_for_page_to_load("30000")
        try: self.failUnless(sel.is_text_present("Register for access to Express"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.go_back()
        for i in range(60):
            try:
                if sel.is_element_present("link=OpenShift Express User Guide"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("link=OpenShift Express User Guide")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "OpenShift Express User Guide" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.go_back()
        for i in range(60):
            try:
                if sel.is_element_present("//a[contains(@href, 'https://www.redhat.com/openshift/sites/default/files/documents/RHOS_Express_Eval_Guide.pdf')]"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        for i in range(60):
            try:
                if sel.is_element_present("//a[contains(@href, 'https://www.redhat.com/openshift/sites/default/files/documents/RHOS_Express_Getting_Started_w_Drupal.pdf')]"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        for i in range(60):
            try:
                if sel.is_element_present("//a[contains(@href, 'https://www.redhat.com/openshift/sites/default/files/documents/RHOS_Express_Getting_Started_w_MediaWiki.pdf')]"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        for i in range(60):
            try:
                if sel.is_element_present("//a[contains(text(),'More Documentation>')]"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("link=More Documentation>")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "Documents | Red Hat Openshift Forum" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.go_back()
        for i in range(60):
            try:
                if "OpenShift by Red Hat | Express" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        for i in range(60):
            try:
                if sel.is_element_present("//div[@id='doc_link']/a[1]/h3"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("//div[@id='doc_link']/a[1]/p")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "Knowledge Base | Red Hat Openshift Forum" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.go_back()
        for i in range(60):
            try:
                if sel.is_element_present("//div[@id='doc_link']/a[2]/h3"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("//div[@id='doc_link']/a[2]/h3")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "Documents | Red Hat Openshift Forum" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.go_back()
        for i in range(60):
            try:
                if sel.is_element_present("link=More information >"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("link=More information >")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "Frequently Asked Questions | Red Hat Openshift Forum" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.go_back()
        for i in range(60):
            try:
                if sel.is_element_present("link=Install"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("link=Install")
        for i in range(60):
            try:
                if sel.is_element_present("link=Create"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("link=Create")
        for i in range(60):
            try:
                if sel.is_element_present("link=Deploy"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("link=Deploy")
        for i in range(60):
            try:
                if sel.is_element_present("//img[@alt='OpenShift Express Product Tour']"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("//img[@alt='OpenShift Express Product Tour']")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "OpenShift by Red Hat | Watch OpenShift Express Product Tour" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.go_back()
        for i in range(60):
            try:
                if sel.is_element_present("link=Watch the video >>>"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("//a[contains(text(),'Watch the video >>>')]")
        for i in range(60):
            try:
                if "YouTube - OpenShift Express -- Install the OpenShift Express Client Tools" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.go_back()
        for i in range(60):
            try:
                if sel.is_element_present("link=Read more >"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("//div[@id='product_community']/div[1]/a")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "News from Summit | Red Hat Openshift Forum" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.go_back()
        for i in range(60):
            try:
                if sel.is_element_present("//div[@id='product_community']/div[2]/a"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("link=Watch this >")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "OpenShift Express -- Getting Started with Drupal | Red Hat Openshift Forum" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.go_back()
        for i in range(60):
            try:
                if sel.is_element_present("//div[@id='product_videos']/a"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("//div[@id='product_videos']/a")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "Videos | Red Hat Openshift Forum" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.go_back()
        for i in range(60):
            try:
                if sel.is_element_present("//div[@id='product_community']/div[3]/a"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("//div[@id='product_community']/div[3]/a")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "Installing OpenShift Express client tools on non RPM based systems | Red Hat Openshift Forum" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.go_back()

    def test_check_express_contents(self):
        sel = self.selenium
        sel.open("/app/")
        for i in range(60):
            try:
                if sel.is_element_present("link=Express"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Express"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("link=Express")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "Try it now!" == sel.get_text("//div[@id='banner']/a"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.assertEqual("Try it now!", sel.get_text("//div[@id='banner']/a"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("link=Install"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Install"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("link=Install")
        for i in range(60):
            try:
                if "Download and install the OpenShift Express client tools so you can deploy and manage your application in the cloud." == sel.get_text("//div[@id='step_1']/p"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.assertEqual("Download and install the OpenShift Express client tools so you can deploy and manage your application in the cloud.", sel.get_text("//div[@id='step_1']/p"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("link=Create"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Create"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("link=Create")
        for i in range(60):
            try:
                if "Create a subdomain for your application and clone the Git master repository from the cloud." == sel.get_text("//div[@id='step_2']/p"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.assertEqual("Create a subdomain for your application and clone the Git master repository from the cloud.", sel.get_text("//div[@id='step_2']/p"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("link=Deploy"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Deploy"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("link=Deploy")
        for i in range(60):
            try:
                if "Add your application code to the Git repository and push to the cloud. Congratulations, your application is live!" == sel.get_text("//div[@id='step_3']/p"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.assertEqual("Add your application code to the Git repository and push to the cloud. Congratulations, your application is live!", sel.get_text("//div[@id='step_3']/p"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_element_present("link=OpenShift Express User Guide"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_element_present("link=OpenShift Express Evaluation Guide"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_element_present("link=Deploying Drupal on OpenShift Express"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_element_present("link=Deploying MediaWiki on OpenShift Express"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_element_present("link=More Documentation>"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_element_present("//div[@id='doc_link']/a[1]/h3"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_element_present("//div[@id='doc_link']/a[2]/h3"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_element_present("link=More information >"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_element_present("link=Read more >"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_element_present("link=Watch this >"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_element_present("link=More Videos >"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_element_present("link=Read this >"))
        except AssertionError, e: self.verificationErrors.append(str(e))


    def test_b_un_authenticated_access_express(self):
        sel = self.selenium
        sel.open("/app/")
        for i in range(60):
            try:
                if sel.is_element_present("link=Login"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Login"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("link=Express"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Express"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("link=Express")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "OpenShift by Red Hat | Express" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        for i in range(60):
            try:
                if "Try it now!" == sel.get_text("//div[@id='banner']/a"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.assertEqual("Try it now!", sel.get_text("//div[@id='banner']/a"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("//div[@id='banner']/a")
        sel.wait_for_page_to_load("30000")
        try: self.failUnless(sel.is_text_present("Register for access to Express"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.go_back()
    
    def test_c_request_access_express(self):
        sel = self.selenium
        sel.open("/app/")
        for i in range(60):
            try:
                if sel.is_element_present("link=Login"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Login"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("link=Login")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_element_present("login_input"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("login_input"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.type("login_input", new_userlist[3])
        sel.type("pwd_input",password)
        sel.click("//input[@value='Login']")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_element_present("link=OpenShift Legal Terms and Conditions"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=OpenShift Legal Terms and Conditions"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("term_submit")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_element_present("link=Logout"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Logout"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("link=Express"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Express"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("link=Express")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "OpenShift by Red Hat | Express" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        for i in range(60):
            try:
                if "Try it now!" == sel.get_text("//div[@id='banner']/a"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.assertEqual("Try it now!", sel.get_text("//div[@id='banner']/a"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("//div[@id='banner']/a")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_text_present("Request Access to Express"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_text_present("Request Access to Express"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("access_express_request_submit")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "OpenShift by Red Hat | Get Access to OpenShift Express!" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        for i in range(60):
            try:
                if sel.is_text_present("Check your inbox for an email letting you know you have been granted access"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_text_present("Check your inbox for an email letting you know you have been granted access"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("link=Logout"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Logout"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("link=Logout")
        sel.wait_for_page_to_load("30000")


    def test_d_granted_getting_started_express(self):
        sel = self.selenium
        sel.open("/app/")
        for i in range(60):
            try:
                if sel.is_element_present("link=Login"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Login"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("link=Login")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_element_present("login_input"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("login_input"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.type("login_input", new_userlist[3])
        sel.type("pwd_input",password)
        sel.click("//input[@value='Login']")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_element_present("link=Logout"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Logout"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("link=Get Started!"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Get Started!"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("link=Get Started!")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "OpenShift by Red Hat | Get Started with Express" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        for i in range(60):
            try:
                if "Get started with Express" == sel.get_text("subtitle"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        for i in range(60):
            try:
                if sel.is_text_present("Getting Started"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_text_present("Congratulations, your Express account is now activated! Now it's time to start creating applications."))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_text_present("Step 1 - Install the client tools"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_text_present("Red Hat Enterprise Linux / Fedora Instructions"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_text_present("Note: Red Hat Enterprise Linux 6 and above are required for the client tools."))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_text_present("Download the express repo file openshift.repo and place it in your /etc/yum.repos.d/ directory"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_text_present("Install the client tools:"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_text_present("$ sudo yum install rhc"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_text_present("Mac Instructions"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_text_present("Install the gem from our site:"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_text_present("$ sudo gem install --source http://gems.rubyforge.org --source https://stg.openshift.redhat.com/app/repo/ rhc"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        try: self.failUnless(sel.is_text_present("Windows Instructions (requires cygwin)"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("link=openshift.repo"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=openshift.repo"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("link=openshift.repo")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_text_present("[openshift-express]"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_text_present("[openshift-express]"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.go_back()
        for i in range(60):
            try:
                if sel.is_element_present("link=exact:http://www.cygwin.com"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=exact:http://www.cygwin.com"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("link=exact:http://rubyforge.org/projects/rubygems"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=exact:http://rubyforge.org/projects/rubygems"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("link=Videos, Tutorials"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("link=Videos, Tutorials")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "OpenShift by Red Hat | Express" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.go_back()
        for i in range(60):
            try:
                if sel.is_element_present("link=Technical Documentation"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("link=Technical Documentation")
        sel.wait_for_page_to_load("30000")
        sel.go_back()
        for i in range(60):
            try:
                if sel.is_element_present("link=Logout"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Logout"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("link=Logout")
        sel.wait_for_page_to_load("30000")
    
    def tearDown(self):
        self.selenium.stop()
        self.assertEqual([], self.verificationErrors)

class g_Flex(unittest.TestCase):
    def setUp(self):
        self.verificationErrors = []
        self.selenium = selenium(host, port, browser, url)
        self.selenium.start()
    
    def test_check_flex_contents(self):
        sel = self.selenium
        sel.open("/app/")
        for i in range(60):
            try:
                if sel.is_element_present("link=Flex"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("link=Flex")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "OpenShift Flex" == sel.get_text("//div[@id='banner']/h2"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        for i in range(60):
            try:
                if "Try it now!" == sel.get_text("//div[@id='banner']/a"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        for i in range(60):
            try:
                if sel.is_element_present("link=Build"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("link=Build")
        for i in range(60):
            try:
                if sel.is_text_present("OpenShift Flex's wizard driven interface makes it easy to provision resources and build integrated application stacks."): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        for i in range(60):
            try:
                if sel.is_element_present("link=Deploy"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("link=Deploy")
        for i in range(60):
            try:
                if "OpenShift Flex makes it easy to deploy your application, make modifications to code and components, version your changes and redeploy." == sel.get_text("//div[@id='step_2']/p"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        for i in range(60):
            try:
                if sel.is_element_present("link=Monitor & Scale"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("link=Monitor & Scale")
        for i in range(60):
            try:
                if "Without the use of agents or scripts, OpenShift Flex gives you end-to-end monitoring straight-out-of-box with configurable auto-scaling that lets you decide when and how to scale your application." == sel.get_text("//div[@id='step_3']/p"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        for i in range(60):
            try:
                if sel.is_element_present("link=OpenShift Flex User Guide"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        for i in range(60):
            try:
                if sel.is_element_present("link=OpenShift Flex Evaluation Guide"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        for i in range(60):
            try:
                if sel.is_element_present("link=Deploying Drupal on OpenShift Flex"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        for i in range(60):
            try:
                if sel.is_element_present("link=Deploying JBoss Applications on OpenShift Flex"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        for i in range(60):
            try:
                if "Community Highlights" == sel.get_text("//div[@id='product_community']/h2"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        for i in range(60):
            try:
                if "Videos" == sel.get_text("//div[@id='product_videos']/h2"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
    

    def test_check_flex_links(self):
        sel = self.selenium
        sel.open("/app/flex")
        for i in range(60):
            try:
                if "Try it now!" == sel.get_text("//div[@id='banner']/a"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.assertEqual("Try it now!", sel.get_text("//div[@id='banner']/a"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("//div[@id='banner']/a")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "Register for access to Flex" == sel.get_text("//div[@id='registration']/h3"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.go_back()
        for i in range(60):
            try:
                if sel.is_element_present("link=Build"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("link=Build")
        for i in range(60):
            try:
                if "OpenShift Flex's wizard driven interface makes it easy to provision resources and build integrated application stacks." == sel.get_text("//div[@id='step_1']/p"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.assertEqual("OpenShift Flex's wizard driven interface makes it easy to provision resources and build integrated application stacks.", sel.get_text("//div[@id='step_1']/p"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("link=Deploy"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("link=Deploy")
        for i in range(60):
            try:
                if "OpenShift Flex makes it easy to deploy your application, make modifications to code and components, version your changes and redeploy." == sel.get_text("//div[@id='step_2']/p"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.assertEqual("OpenShift Flex makes it easy to deploy your application, make modifications to code and components, version your changes and redeploy.", sel.get_text("//div[@id='step_2']/p"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("link=Monitor & Scale"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("link=Monitor & Scale")
        for i in range(60):
            try:
                if "Without the use of agents or scripts, OpenShift Flex gives you end-to-end monitoring straight-out-of-box with configurable auto-scaling that lets you decide when and how to scale your application." == sel.get_text("//div[@id='step_3']/p"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.assertEqual("Without the use of agents or scripts, OpenShift Flex gives you end-to-end monitoring straight-out-of-box with configurable auto-scaling that lets you decide when and how to scale your application.", sel.get_text("//div[@id='step_3']/p"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("link=OpenShift Flex User Guide"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("link=OpenShift Flex User Guide")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "OpenShift Flex User Guide" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.go_back()
        for i in range(60):
            try:
                if sel.is_element_present("//a[contains(@href, 'https://www.redhat.com/openshift/sites/default/files/documents/RHOS_Flex_Eval_Guide.pdf')]"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("//a[contains(@href, 'https://www.redhat.com/openshift/sites/default/files/documents/RHOS_Flex_Eval_Guide.pdf')]"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("//a[contains(text(),'Deploying Drupal on OpenShift Flex')]"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("//a[contains(text(),'Deploying Drupal on OpenShift Flex')]"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("//a[contains(text(),'Deploying JBoss Applications on OpenShift Flex')]"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("//a[contains(text(),'Deploying JBoss Applications on OpenShift Flex')]"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("//a[contains(text(),'More Documentation >')]"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("//a[contains(text(),'More Documentation >')]"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("//a[contains(text(),'More Documentation >')]")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "Documents | Red Hat Openshift Forum" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.go_back()
        for i in range(60):
            try:
                if sel.is_element_present("//div[@id='doc_link']/a[1]/p"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("//div[@id='doc_link']/a[1]/h3")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "Knowledge Base | Red Hat Openshift Forum" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.go_back()
        for i in range(60):
            try:
                if sel.is_element_present("//div[@id='doc_link']/a[2]/p"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("//div[@id='doc_link']/a[2]/h3"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("//div[@id='doc_link']/a[2]/p")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "Documents | Red Hat Openshift Forum" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.go_back()
        for i in range(60):
            try:
                if sel.is_element_present("//img[@alt='OpenShift Flex Product Tour']"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("//img[@alt='OpenShift Flex Product Tour']"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("//img[@alt='OpenShift Flex Product Tour']")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "OpenShift by Red Hat | Watch OpenShift Flex Product Tour" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.go_back()
        for i in range(60):
            try:
                if sel.is_element_present("//img[@alt='Developers, ISVs, customers and partners']"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("//img[@alt='Developers, ISVs, customers and partners']")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "OpenShift by Red Hat | Watch Developers, ISVs, customers and partners" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.go_back()
        for i in range(60):
            try:
                if sel.is_element_present("//a[contains(@href, 'https://www.redhat.com/openshift/forums/news-and-announcements/news-from-summit')]"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.click("//a[contains(@href, 'https://www.redhat.com/openshift/forums/news-and-announcements/news-from-summit')]")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "News from Summit | Red Hat Openshift Forum" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.go_back()
        for i in range(60):
            try:
                if sel.is_element_present("link=Read this >"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("//a[contains(@href, 'https://www.redhat.com/openshift/sites/default/files/documents/RHOS_Flex_Getting_Started_w_JBoss.pdf')]"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("//div[@id='product_videos']/a"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("//div[@id='product_videos']/a"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("//div[@id='product_videos']/a")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "Videos | Red Hat Openshift Forum" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        sel.go_back()

    def test_un_authenticated_request_flex(self):
        sel = self.selenium
        sel.open("/app")
        for i in range(60):
            try:
                if sel.is_element_present("link=Login"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Login"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        for i in range(60):
            try:
                if sel.is_element_present("link=Flex"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Flex"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("link=Flex")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "Try it now!" == sel.get_text("//div[@id='banner']/a"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.assertEqual("Try it now!", sel.get_text("//div[@id='banner']/a"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("//div[@id='banner']/a")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_text_present("Register for access to Flex"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_text_present("Register for access to Flex"))
        except AssertionError, e: self.verificationErrors.append(str(e))    

    
    def test_authenticated_request_flex(self):
        sel = self.selenium
        sel.open("/app/login")
        for i in range(60):
            try:
                if sel.is_element_present("link=Login"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Login"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.type("login_input", new_userlist[2])
        sel.type("pwd_input",password)
        sel.click("//input[@value='Login']")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_element_present("link=OpenShift Legal Terms and Conditions"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=OpenShift Legal Terms and Conditions"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("term_submit")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_element_present("link=Logout"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Logout"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("link=Flex")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "Try it now!" == sel.get_text("//div[@id='banner']/a"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.assertEqual("Try it now!", sel.get_text("//div[@id='banner']/a"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("//div[@id='banner']/a")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if "OpenShift by Red Hat | Get Access to OpenShift Flex!" == sel.get_title(): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        for i in range(60):
            try:
                if sel.is_element_present("access_flex_request_ec2_account_number"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("access_flex_request_ec2_account_number"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.type("access_flex_request_ec2_account_number", "5599-4310-1436")
        sel.click("access_flex_request_submit")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_text_present("Check your inbox for an email letting you know you have been granted access"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_text_present("Check your inbox for an email letting you know you have been granted access"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("link=Logout")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_element_present("link=Login"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Login"))
        except AssertionError, e: self.verificationErrors.append(str(e))


    
    def test_granted_getting_started_flex(self):
        sel = self.selenium
        sel.open("/app/")
        sel.click("link=Login")
        sel.wait_for_page_to_load("30000")
        sel.type("login_input", old_userlist[0])
        sel.type("pwd_input", "123456")
        sel.click("//input[@value='Login']")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_element_present("flex_console_link"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("flex_console_link"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("flex_console_link")
        sel.wait_for_page_to_load("30000")
        sel.go_back()
        for i in range(60):
            try:
                if sel.is_element_present("link=Logout"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Logout"))
        except AssertionError, e: self.verificationErrors.append(str(e))
        sel.click("link=Logout")
        sel.wait_for_page_to_load("30000")
        for i in range(60):
            try:
                if sel.is_element_present("link=Login"): break
            except: pass
            time.sleep(1)
        else: self.fail("time out")
        try: self.failUnless(sel.is_element_present("link=Login"))
        except AssertionError, e: self.verificationErrors.append(str(e))
    

    def tearDown(self):
        self.selenium.stop()
        self.assertEqual([], self.verificationErrors)
 


if __name__ == "__main__":
    unittest.main()
    # HTMLTestRunner.main()
