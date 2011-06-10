from selenium import selenium
import unittest, time, re
#import HTMLTestRunner
import sys
import string

password="redhat"
browser="*firefox /usr/lib64/firefox-3.6/firefox"
host="localhost"
url="https://stg.openshift.redhat.com"
port=54119

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

    def tearDown(self):
        self.selenium.stop()
        self.assertEqual([], self.verificationErrors)
 


if __name__ == "__main__":
    unittest.main()
