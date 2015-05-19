import sys
import pygame
from pygame import *
from pygame.locals import *
from pygame.sprite import *
from random import *
import socket
import Sensing
import re
import sys
import time

port = 7000
hits = 0
# set the start flag
flag = 1

class Mole(Sprite):
    # grass play background loaded
    def __init__(self):
        Sprite.__init__(self)
        self.image = image.load("1.png")
	
        self.rect = self.image.get_rect()
	self.rect.center = (500, 360)

    # moles punched background
    def knock1(self):
        self.image = image.load("1knock.png")
        self.rect = self.image.get_rect()
        self.rect.center = (500, 360)
    def knock2(self):
        self.image = image.load("2knock.png")
        self.rect = self.image.get_rect()
        self.rect.center = (500, 360)
    def knock3(self):
        self.image = image.load("3knock.png")
        self.rect = self.image.get_rect()
        self.rect.center = (500, 360)
    def knock4(self):
        self.image = image.load("4knock.png")
        self.rect = self.image.get_rect()
        self.rect.center = (500, 360)

    #grass play background
    def normal(self):
        self.image = image.load("1.png")
        self.rect = self.image.get_rect()
	self.rect.center = (500, 360)  

class Welcome(Sprite):
    # start background
    def __init__(self):
        Sprite.__init__(self)
        self.image = image.load("play.png")	
        self.rect = self.image.get_rect()
	self.rect.center = (500, 360)
    # ending background
    def left(self):
        self.image = image.load("left.png")
        self.rect = self.image.get_rect()
        self.rect.center = (500, 360)
    # ending background
    def right(self):
        self.image = image.load("right.png")

        self.rect = self.image.get_rect()
	self.rect.center = (500, 360)
#draw texts and update background to the screen and wait for 0.5s
def scrprt():
    sprites.update()
    t = f.render("Hits = " + str(hits), False, (255,255,255))
    screen.blit(t, (450, 40))    
    sprites.draw(screen)
    display.update()
    time.sleep(0.5)


#main
pygame.init()
welconme = Welcome()
#socket defination
s = socket.socket(socket.AF_INET6, socket.SOCK_DGRAM)
s.bind(('', port))

#the window size
screen = display.set_mode((1000, 720))

#draw start background to the screen
sprites5 = Group(welconme)
sprites5.update()
sprites5.draw(screen)
display.update()

#set mouse even
ev = event.wait()
mixer.Sound("play.wav").play()
# flag is used to get out of the while
while flag == 1:
	#wait 
    ev = event.wait()
	
    if ev.type == MOUSEBUTTONDOWN:
		
            flag = 0
	    mole = Mole()
	    # draw grass play background to screen
	    sprites = Group(mole)
	    sprites.update()
	    sprites.draw(screen)
        # draw text to screen
	    f = font.Font("Impact.ttf", 45)
	    t = f.render("Hits = " + str(hits), False, (255,255,255))
	    screen.blit(t, (450, 40)) 
	    display.update()


while True:
    #set timer to 30s
    p = 30.00
    a = time.time()
    n = 0

    while True:
        n = time.time()
        if n  > a + p:
            if flag == 0:
		flag +=1
	    	mixer.Sound("gameover.wav").play()
            
	    welconme.left()
	    sprites5.update()
	    sprites5.draw(screen)
	    c = font.Font("Impact.ttf", 30)
	    c = f.render("Score: " + str(hits), False, ((215,90,80)))
            
            screen.blit(c, (450, 200))
	    display.update()
            time.sleep(0.5) 
	    welconme.right()
	    sprites5.update()
            sprites5.draw(screen)
	    c = font.Font("Impact.ttf", 30)
            
	    c = f.render("Score: " + str(hits), False, ((215,90,80)))

            
            screen.blit(c, (450, 200))
	    display.update()
            time.sleep(0.5)
           
	else:
            mole.normal()  
           
            
            sprites.update()
            sprites.draw(screen)
	    t = f.render("Hits = " + str(hits), False, (255,255,255))
            screen.blit(t, (450, 40))
            display.update()
            	
            data, addr = s.recvfrom(1024)

            # hits different moles by identifying the node id
            if (len(data) > 0):	
        	mixer.Sound("hit.wav").play()
        	hits += 1
                addrstr = str(addr)
        	if int(addrstr[8]) == 2:
        	    mole.knock1()    	
        	    scrprt()
        	elif int(addrstr[8]) == 3:
        	    mole.knock2()
        	    scrprt()
        	elif int(addrstr[8]) == 4:
        	    mole.knock3()
                    scrprt()
        	elif int(addrstr[8]) == 8:   
        	    mole.knock4()    	
        	    scrprt()
        

