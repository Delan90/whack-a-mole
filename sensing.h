#ifndef SENSING_H_
#define SENSING_H_

enum {
  AM_SENSING_REPORT = -1,

};


//define sending information
typedef nx_struct settings {
  nx_uint16_t threshold; //we need set threshold at the beginning and send it to other nodes.
  nx_uint32_t blink_time;//Set the blinking time as different difficulty level. 
                         //We cover the sensor when the light is blink, then we successfully get a point.
} settings_t;

//the information needed to send to other nodes
nx_struct sensing_report {
  nx_uint16_t sender;//sender's ID
  nx_uint8_t type;   //need to set a type for node to self-adeptive
  nx_uint8_t counter;//counte the points
} ;

#define ROUTER "fec0::100"
#define REPORT_DEST "ff02::1"
#define MULTICAST "ff02::1"

#endif
