# Why you need firemware update?
The encoder simulates the process of pressing and releasing the button.
The number of  plug-ins and aircraft installed by each person is different, the delay of the system cannot be determined, so it is necessary to test an optimal delay time, in milliseconds.
If the button interval is short, the game will be considered as interference and filtered out. If the button interval is long, there will be some delay.

#### If you turn encoder slowly,step by step, it lost in the game ,you need try update the firemware.

In the acceleration script, there is also a time value, which is to determine how fast the rotation speed is to start the acceleration, so when testing first, do not use the acceleration script to test (QGMC710.lua in FlyWithLua Scripts)

# Update steps:
1. Go to the [Driver] folder in the update directory.Install the driver for the "dpinst_amd64.exe" or" dpinst_x86.exe" program. (a system only need to install once, skip this step next time)
2. Push and hold the CRS2 encoder button, plug in the USB, and release the CRS2 button after hearing the USB access sound.
 *  Now the QGMC710 backlight is fully lit, the system will automatically install the driver and wait for a while to install successfully."STM Device in DFU Mode" appears in the System Device Manager

3. Edit the "QGMC710_Update.bat" file. Change the file name . `xdfu.exe -r -c -d --v --fn "QGMC710_181214.dfu"`  default file name is  "QGMC710_181214.dfu" .It's interval 20ms.

  * If lost steps, you can try 25ms - 30ms - 40ms one by one , most 30ms good.

4. Run the QGMC710_Update.bat file, and waitting successful.

5.Enter the game, try. If not good, repeat 2-4 steps.

#### Don't warry will damage the chip,it's safe and easy.
