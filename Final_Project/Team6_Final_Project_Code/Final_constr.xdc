# Constraints for the four-digit seven-segment display

# LED
set_property PACKAGE_PIN W7 [get_ports {cathode[6]}]                    
   set_property IOSTANDARD LVCMOS33 [get_ports {cathode[6]}]
set_property PACKAGE_PIN W6 [get_ports {cathode[5]}]                    
   set_property IOSTANDARD LVCMOS33 [get_ports {cathode[5]}]
set_property PACKAGE_PIN U8 [get_ports {cathode[4]}]                    
   set_property IOSTANDARD LVCMOS33 [get_ports {cathode[4]}]
set_property PACKAGE_PIN V8 [get_ports {cathode[3]}]                    
   set_property IOSTANDARD LVCMOS33 [get_ports {cathode[3]}]
set_property PACKAGE_PIN U5 [get_ports {cathode[2]}]                    
   set_property IOSTANDARD LVCMOS33 [get_ports {cathode[2]}]
set_property PACKAGE_PIN V5 [get_ports {cathode[1]}]                    
   set_property IOSTANDARD LVCMOS33 [get_ports {cathode[1]}]
set_property PACKAGE_PIN U7 [get_ports {cathode[0]}]                    
   set_property IOSTANDARD LVCMOS33 [get_ports {cathode[0]}]
   
set_property PACKAGE_PIN U2 [get_ports {anode[0]}]                    
   set_property IOSTANDARD LVCMOS33 [get_ports {anode[0]}]
set_property PACKAGE_PIN U4 [get_ports {anode[1]}]                    
   set_property IOSTANDARD LVCMOS33 [get_ports {anode[1]}]
set_property PACKAGE_PIN V4 [get_ports {anode[2]}]               
   set_property IOSTANDARD LVCMOS33 [get_ports {anode[2]}]
set_property PACKAGE_PIN W4 [get_ports {anode[3]}]          
   set_property IOSTANDARD LVCMOS33 [get_ports {anode[3]}]

#sensors for score
set_property PACKAGE_PIN B16 [get_ports {track1}]
set_property IOSTANDARD LVCMOS33 [get_ports {track1}]
set_property PACKAGE_PIN C16 [get_ports {track2}]
set_property IOSTANDARD LVCMOS33 [get_ports {track2}]
set_property PACKAGE_PIN P18 [get_ports {track3}]
set_property IOSTANDARD LVCMOS33 [get_ports {track3}]
set_property PACKAGE_PIN R18 [get_ports {track4}]
set_property IOSTANDARD LVCMOS33 [get_ports {track4}]
set_property PACKAGE_PIN N1 [get_ports {track5}]
set_property IOSTANDARD LVCMOS33 [get_ports {track5}]
#MOTOR
set_property PACKAGE_PIN N2 [get_ports {track6}]
set_property IOSTANDARD LVCMOS33 [get_ports {track6}]
set_property PACKAGE_PIN G2 [get_ports motor_servo]
set_property IOSTANDARD LVCMOS33 [get_ports motor_servo]
#clock
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name clock -waveform {0.000 5.000} -add [get_ports clk]
#rst
set_property PACKAGE_PIN U18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

set_property CONFIG_VOLTAGE 3.3 [current_design]
## where value1 is either VCCO(for Vdd=3.3) or GND(for Vdd=1.8)
set_property CFGBVS VCCO [current_design]