1-To Build the Maincore as well as the subcore run the below script in terminal inside maincore =>
  ./build_script_training_telechip8050.sh


1=> Maincore Build press 1

    For Maincore make sure these config alredy set if not set,set these config selecting option=> "Change Build Config (MainCore)"
            
            | Build Board         : tcc8050 	                
            | Build Board version : evb_sv1.0                     
            | Android Versrion    : Android-10                      
            | Build Platform      : arm64                          
            | Option eng/user     : userdebug 		        
            | Storage             : UFS 	                       
            | Head-Up Display     : No 	                      
            | GPU Virtualization  : Yes 	                       
            | Suspend-To-Ram      : No 


2=> Subcore Build press 2

    For Maincore make sure these config alredy set if not set,set these config selecting option=> "Change Build Config (SubCore)"

            | SDK         : tcc805x_android_ivi                      
            | MANIFEST    : tcc805x_android_subcore.xml              |
            | MACHINE     : tcc8050-sub                              |
            | VERSION     : release                                  |
            | FEATURES    : meta-micom,meta-update,rvc,early-camera  |
            |		        ,kernel-4.14,ufs,gpu-vz,cluster       |

      Note:=>1-From the analysis if we are flashing the binaries and only maincore logo appears an not booting, then it might be due to the problem with subcore images,verify the subcore images if all 		the images less than 400mb then it might not be build propely then do the below step.

      Note:=>2-After subcore build successfull ,check the tools ,buildtools and source-mirror are present or not in subcore.if not present or not fully downloaded.
		then copy these files from "Essential_folder_for_Subcore" folder into the subcore,and build again the subcore. 

            
            
3=> for flashing use this script "FLASH_IMAGE_Telechip_8050_Training.sh" 
	location of the script should be in mydroid where mauncore and sucore situated.
	
	
4=>For Enabling and disabling maincore touchscreen open the dts file "tcc8050-android-lpd4x322_sv1.0.dts"   Note => we have also "tcc8050-android-lpd4x322_sv0.1.dts" , we are using "sv1.0".
   Files and location for enabling and disabling maincore touchscreen.
   	=> "maincore/kernel/arch/arm/boot/dts/tcc/tcc8050-android-lpd4x322_sv1.0.dts"
	=> patch file for enabling and disabling disabling maincore touchscreen "maincore_touch_screen_disable.patch".
	
	
	
5=> For cross compiling c file for telchip8050 use the below below script 
	"build_hello_telechip.sh"
	inside the above script we have set the below path 
	"export PATH=~/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin:\$PATH"

	we have also "gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf/bin" we can use both the compiler. 
	
