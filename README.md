# whack-a-mole

##Introduction

This is a whack a mole game based on tinyOS and python game. 
In this project, four telosb mote are used as moles, one ppp router is used as controller. 
The game is controlled by a python game, which is used to receive the data from the telosb mote and display the result as a python game. 

The demo of this project can be checked in https://www.youtube.com/watch?v=AAMDzTGoMbw&amp;spfreload=10

##Hardware

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

##Sofeware

TinyOS is a free and open source software component-based operating system and platform targeting wireless sensor networks (WSNs). TinyOS is an embedded operating system written in the nesC programming language as a set of cooperating tasks and processes. It is intended to be incorporated into smartdust. TinyOS started as a collaboration between the University of California, Berkeley in co-operation with Intel Research and Crossbow Technology, and has since grown to be an international consortium, the TinyOS Alliance.

###Implementation of Tiny OS

TinyOS applications are written in nesC, a dialect of the C language optimized for the memory limits of sensor networks. Its supplementary tools are mainly in the form of Java and shell script front-ends. Associated libraries and tools, such as the nesC compiler and Atmel AVR binutils toolchains, are mostly written in C.

TinyOS programs are built out of software components, some of which present hardware abstractions. Components are connected to each other using interfaces. TinyOS provides interfaces and components for common abstractions such as packet communication, routing, sensing, actuation and storage.

TinyOS is completely non-blocking: it has one stack. Therefore, all I/O operations that last longer than a few hundred microseconds are asynchronous and have a callback. To enable the native compiler to better optimize across call boundaries, TinyOS uses nesC's features to link these callbacks, called events, statically. While being non-blocking enables TinyOS to maintain high concurrency with one stack, it forces programmers to write complex logic by stitching together many small event handlers. To support larger computations, TinyOS provides tasks, which are similar to a deferred procedure call and interrupt handler bottom halves. A TinyOS component can post a task, which the OS will schedule to run later. Tasks are non-preemptive and run in FIFO order. This simple concurrency model is typically sufficient for I/O centric applications, but its difficulty with CPU-heavy applications has led to the development of a thread library for the OS, named TOSThreads.

TinyOS code is statically linked with program code and is compiled into a small binary, using a custom GNU toolchain. Associated utilities are provided to complete a development platform for working with TinyOS.

