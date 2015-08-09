# whack-a-mole

##Introduction

This is a whack a mole game based on tinyOS and python game. 
In this project, four telosb mote are used as moles, one ppp router is used as controller. 
The game is controlled by a python game, which is used to receive the data from the telosb mote and display the result as a python game. 

The demo of this project can be checked in https://www.youtube.com/watch?v=AAMDzTGoMbw&amp;spfreload=10

##Hardware : TelosB

This project based on the telosb mote which is a Low Power Wireless Sensor Module, TelosB:

(TPR2400 Datasheet can be found here : http://www.willow.co.uk/TelosB_Datasheet.pdf )

- IEEE 802.15.4 compliant 
- 250 kbps, High Data Rate Radio 
- TI MSP430 microcontroller with 10kB RAM 
- Integrated onboard antenna 
- Data collection and programming via USB 
- Open-source operating system 
- Optional integrated temperature and humidity sensor 
- Developed and published to the research community by UC Berkeley 

![My Unicorn](http://moodle.utc.fr/file.php/498/SupportWeb/res/telosb-recto.png)

##Sofeware : Tiny OS

TinyOS is a free and open source software **component-based operating system** and platform targeting **wireless sensor networks (WSNs)**. TinyOS is an *embedded operating system* written in the [nesC programming language](https://en.wikipedia.org/wiki/NesC) as a set of cooperating tasks and processes. It is intended to be incorporated into smartdust. TinyOS started as a collaboration between the University of California, Berkeley in co-operation with Intel Research and Crossbow Technology, and has since grown to be an international consortium, the TinyOS Alliance.

Details can be found on wiki :https://en.wikipedia.org/wiki/TinyOS

Tutorial of the Tiny OS : https://github.com/tinyos/tinyos-main

##Basic idea of this project

With this project, we want to achieve four functions to practice the Tiny OS with the telosB mote:
- Implementing a **random timer** to make the mote shining randomly; 
- Synchronizing the settings with **multicast**. By this function,every time we change the settings of one mote, the ohter mote will be Synchronized by multicast;
- Achieveing the Self-adaptive function by sending request to other mote when booting to get the systems's settings;
- Using the [pygame](http://www.pygame.org/news.html) to display the results. Each mote will **broadcast** their data to ppp router, we implement a pygame script to display the data from the motes as a funny game.

(All of the multicast and broadcast is using the [UDP](https://en.wikipedia.org/wiki/User_Datagram_Protocol)



