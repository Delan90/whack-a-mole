#include "StorageVolumes.h"

configuration SensingC {

} implementation {
	components MainC, LedsC, SensingP;
	SensingP.Boot -> MainC;
	SensingP.Leds -> LedsC;

	components IPStackC;
	components RPLRoutingC;
	components StaticIPAddressTosIdC;
	SensingP.RadioControl -> IPStackC;

	//define the interfae for multicasting
        components new UdpSocketC() as Settings;
	SensingP.Settings -> Settings;        
	components new UdpSocketC() as Initial;
	SensingP.Initial -> Initial;

	components new UdpSocketC() as ReportCounter;
	SensingP.ReportCounter -> ReportCounter;


        //define the shell command interface      
	components UDPShellC;
	components new ShellCommandC("get") as GetCmd;
	components new ShellCommandC("set") as SetCmd;
	SensingP.GetCmd -> GetCmd;
	SensingP.SetCmd -> SetCmd;

	//define the interface to read the stream light par
	components new HamamatsuS1087ParC() as SensorPar;
	SensingP.StreamPar -> SensorPar.ReadStream;

	//define the timer we will use in this project:two one shot timer,one period timer
	components new TimerMilliC() as RandomTimer;//one shot timer
	SensingP.RandomTimer -> RandomTimer;
	components new TimerMilliC() as SampleTimer;//period timer
	SensingP.SampleTimer-> SampleTimer;
        components new TimerMilliC() as BlinkTimer;//one shot timer
	SensingP.BlinkTimer -> BlinkTimer;

	components new ConfigStorageC(VOLUME_CONFIG) as LocalSettings;
	SensingP.ConfigMount -> LocalSettings;
	SensingP.ConfigStorage -> LocalSettings;

	//define the interface to generate the random number
	components RandomC;	
	SensingP.Random ->RandomC;
 	SensingP.SeedInit ->RandomC;

        //define the interface to get the local time
	components LocalTimeMicroC;
	SensingP.MicroTime -> LocalTimeMicroC;

}
