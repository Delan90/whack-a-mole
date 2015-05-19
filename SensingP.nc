#include <lib6lowpan/ip.h>
#include "sensing.h"
#include "blip_printf.h"

//We are group 6, we implement the 'whack a mole' game by tinyOS and python game


module SensingP {
	uses {
		interface Boot;
		interface Leds;
		interface SplitControl as RadioControl;
		interface UDP as Settings;
		interface UDP as Initial;
		interface UDP as ReportCounter;	
	
		interface ShellCommand as GetCmd;
		interface ShellCommand as SetCmd;

		interface ReadStream<uint16_t> as StreamPar;

		interface Mount as ConfigMount;
		interface ConfigStorage;

                //Light on the LED randomly and start the sample timer and blink time
		interface Timer<TMilli> as RandomTimer;

		//This is a oneshot timer that used to turn off the LED and sample timer after the "blink time"
		interface Timer<TMilli> as BlinkTimer;

		// This is a sample timer to start the streampar during the LED on state.
		interface Timer<TMilli> as SampleTimer;
		
		// use the random function to generate random number		
		interface Random;  
		// initiate the seed for the random generator
		interface ParameterInit<uint16_t> as SeedInit; 
		// obtain the local time as seed
		interface LocalTime<TMicro> as MicroTime;  
	}
} implementation {
       
	enum {
		RANDOM_TIME = 1024,
		SAMPLE_PERIOD = 100,
		BLINK_TIME = 1024, 
		LOW_LIGHT_THRESHOLD = 20,
		SAMPLE_TIME = 4000, 
		SAMPLE_SIZE =10,
		COUNTER = 0,
	};
	
	enum {
		SETTINGS_REQUEST = 1,
		SETTINGS_RESPONSE = 2,
		SETTINGS_USER = 4,
	};
	

	settings_t settings;
	nx_struct sensing_report stats;
	nx_struct sensing_report test;
	
	struct sockaddr_in6 multicast;
	struct sockaddr_in6 route_dest;
	struct sockaddr_in6 router;
	uint16_t m_parSamples[SAMPLE_SIZE];
	int i;
        int average;
      	int sum;
	uint16_t flag = 0;

	event void Boot.booted() {
		settings.blink_time = BLINK_TIME;
		settings.threshold = LOW_LIGHT_THRESHOLD;
		
		multicast.sin6_port = htons(4000);
		inet_pton6(MULTICAST, &multicast.sin6_addr);

		route_dest.sin6_port = htons(8000);
		inet_pton6(REPORT_DEST, &route_dest.sin6_addr);
		
		router.sin6_port = htons(7000);
		inet_pton6(ROUTER, &router.sin6_addr);

		call Settings.bind(4000);
		call Initial.bind(8000);
		
	
		stats.type = SETTINGS_REQUEST;//initially setting the type for each node as SETTINGS_REQUEST
		stats.counter = COUNTER;
	
                call RadioControl.start();
		call SeedInit.init((uint16_t) call MicroTime.get()); // Using local time to generate seeds
	}

	//radio
	event void RadioControl.startDone(error_t e) {
		call RandomTimer.startOneShot(RANDOM_TIME);
	}
	event void RadioControl.stopDone(error_t e) {}



/*---------------------------------------------config-----------------------------------------------------------------*/
	
	event void ConfigMount.mountDone(error_t e) {
		if (e != SUCCESS) {
			call Leds.led0On();
			call RadioControl.start();
		} else {
			if (call ConfigStorage.valid()) {
				call ConfigStorage.read(0, &settings, sizeof(settings));
			} else {
				settings.blink_time = BLINK_TIME;
				settings.threshold = LOW_LIGHT_THRESHOLD;

				call RadioControl.start();
			}
		}
	}

	event void ConfigStorage.readDone(storage_addr_t addr, void* buf, storage_len_t len, error_t e) {
		call RadioControl.start();
	}

	event void ConfigStorage.writeDone(storage_addr_t addr, void* buf, storage_len_t len, error_t e) {
		call ConfigStorage.commit();
	}

	event void ConfigStorage.commitDone(error_t error) {}




/*---------------------------------------------udp interfaces--------------------------------------------------------*/

        //the interface is used to acheive the self adaptive
        //We initially set the type as SETTINGS_REQUEST and broadcast it at the beginning
	//When other nodes get the paket with the type 'SETTINGS_REQUEST' they will send their current settings to the node with type 'SETTINGS_REQUEST',also the tpye will be changed to 'SETTINGS_RESPONSE' and send out.
        //We set a flag to help node to get the current settings of the other nodes.
        //Initially, the flag is equal to 0(type is 'SETTINGS_REQUEST'. And we will change it to 1 when the type is 'SETTINGS_USER' & 'SETTINGS_RESPONSE'
        // When flag is equal to 1,we will store the settings to the node and change the type of the node to 'SETTINGS_USER'.       
	event void Initial.recvfrom(struct sockaddr_in6 *from, void *data, uint16_t len, struct ip6_metadata *meta) {
		memcpy(&test, data, sizeof(test));
		if (test.type == SETTINGS_REQUEST){
		   stats.type = SETTINGS_RESPONSE;
		   call Initial.sendto(&route_dest, &stats, sizeof(settings_t));
		   call Settings.sendto(&multicast, &settings, sizeof(settings));
		
		}else if (test.type == SETTINGS_USER){
	           flag = 1;
        	}else if (test.type == SETTINGS_RESPONSE){
                   flag = 1;
	           stats.type = SETTINGS_RESPONSE;
       		}

	
	}

	//the interface is used to get the settings from the other nodes
	event void Settings.recvfrom(struct sockaddr_in6 *from, void *data, uint16_t len, struct ip6_metadata *meta) {
	memcpy(&settings, data, sizeof(settings_t));

	if (flag == 1){
		stats.type =  SETTINGS_USER;
		call ConfigStorage.write(0, &settings, sizeof(settings));
		flag =0;
	}
	}
	
        //the interface is used for ppp router to recieve the paket from the nodes
	event void ReportCounter.recvfrom(struct sockaddr_in6 *from, void *data, uint16_t len, struct ip6_metadata *meta) {}

        //shell command to get the current settings of the nodes
	event char *GetCmd.eval(int argc, char **argv) {
		char *ret = call GetCmd.getBuffer(32);
		if (ret != NULL) {
			switch (argc) {
				case 1:
					sprintf(ret, "\t[Blink_Time: %u]\n\t[Threshold: %u]\n\t[counter: %u]\n\t",  (unsigned int )settings.blink_time,(unsigned int )settings.threshold,(unsigned int )stats.counter);
					break;
				case 2: 
					if (!strcmp("bt",argv[1])) {
						sprintf(ret, "\t[Time: %u]\n", (unsigned int )settings.blink_time);
					} else if (!strcmp("th", argv[1])) {
						sprintf(ret, "\t[Threshold: %u]\n",(unsigned int )settings.threshold);
					} else if (!strcmp("ct", argv[1])) {
						sprintf(ret, "\t[counter: %u]\n",(unsigned int )stats.counter);
					}
					break;
				default:
					strcpy(ret, "Usage: get [time|th]\n");
			}
		}
		return ret;
	}


        //shell command to set and change the settings of all of the nodes
	task void report_settings() {
		stats.type = SETTINGS_USER;
		call Initial.sendto(&route_dest, &stats, sizeof(settings_t));
		call Settings.sendto(&multicast, &settings, sizeof(settings));
		call ConfigStorage.write(0, &settings, sizeof(settings));
	}	

	event char *SetCmd.eval(int argc, char **argv) {
		char *ret = call SetCmd.getBuffer(40);
		if (ret != NULL) {

			if (argc == 3) { 
				if (!strcmp("time",argv[1])) {
					settings.blink_time = atoi(argv[2]);
					sprintf(ret, ">>>Time changed to %u\n",(unsigned int )settings.blink_time);
					post report_settings();
				} else if (!strcmp("th", argv[1])) {
					settings.threshold = atoi(argv[2]);
					sprintf(ret, ">>>Threshold changed to %u\n",(unsigned int )settings.threshold);
					post report_settings();
				} 
		                }else {
					strcpy(ret,"Usage: set time|th\n");      }
		}
		return ret;
	}


/*------------------------------------------------timer----------------------------------------------------------------*/

	//The 'RandomTimer' will start at the radio contrl part

	//'RandomTimer' will fire an event which will turn on the LEDs and call 'SampleTimer' & 'BlinkTimer'

	//'SampleTimer' will fire the event to read the light par stream and 
	//compare the average light par to the threshold,if lower than the threshold, the LEDs will be turned off

        //'BlinkTimer' will set the LEDs off and call 'SampleTimer' stop & randomly start another 'RandomTimer'

	//'RandomTimer' & 'BlinkTimer' will alternately call each other randomly
       
	task void blink_event() {
	stats.sender = TOS_NODE_ID;
        call Leds.set(7);
	call BlinkTimer.startOneShot(settings.blink_time);
	call SampleTimer.startPeriodic(SAMPLE_PERIOD);
	}

	event void BlinkTimer.fired() {
	int r;
	r = (call Random.rand16())%5 +1; //generate random number from 1-4	
	call Leds.set(0);
	call SampleTimer.stop();
	call RandomTimer.startOneShot(RANDOM_TIME * r);	
	}

	event  void SampleTimer.fired(){  	
	call StreamPar.postBuffer(m_parSamples, SAMPLE_SIZE);
	call StreamPar.read(SAMPLE_TIME);
	}



	event void RandomTimer.fired() {
	if (stats.type == SETTINGS_REQUEST)
	{
		call Initial.sendto(&route_dest, &stats, sizeof(stats));	
	}
		post blink_event();		
	}


	task void checkStreamPar() {
			
		for (i = 0; i < SAMPLE_SIZE; i++) {
				sum += m_parSamples[i];
                        }  
			average = sum / SAMPLE_SIZE;
			sum = 0;
                        if (average < settings.threshold) {
			                      
			call Leds.set(0);
			stats.counter++;
			call SampleTimer.stop();
			call ReportCounter.sendto(&router, &stats, sizeof(settings));
			}else 
                        {
                        }	        
	}


	event void StreamPar.readDone(error_t ok, uint32_t usActualPeriod) {
		if (ok == SUCCESS) {
			post checkStreamPar();
		}
	}

	event void StreamPar.bufferDone(error_t ok, uint16_t *buf,uint16_t count) {}


}
