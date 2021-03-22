// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
// Date        : Thu Jan 14 21:42:33 2021
// Host        : DESKTOP-ERAKEM0 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               g:/UPM_Master/LabCircuitosYSistemasElectro/ProyectoFinal/PIC_Project.srcs/sources_1/ip/Clk_Gen/Clk_Gen_stub.v
// Design      : Clk_Gen
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module Clk_Gen(clk_out1, reset, locked, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="clk_out1,reset,locked,clk_in1" */;
  output clk_out1;
  input reset;
  output locked;
  input clk_in1;
endmodule
