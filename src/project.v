`define default_netname none

//TinyTapeout Module Definition
module tt_um_monobit (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // Internal signals for mapping
    wire rst = ~rst_n; // Active low reset converted to active high

    // Outputs from monobit instance
    wire is_random_rsc_dat;
    wire is_random_triosy_lz;
    wire valid_rsc_dat;
    wire valid_triosy_lz;
    wire epsilon_triosy_lz;

    // Input mapping
    wire epsilon_rsc_dat = ui_in[0]; // Map ui_in[0] to epsilon input

    // Output mapping
    assign uo_out[0] = is_random_rsc_dat; // Map is_random to uo_out[0]
    assign uo_out[1] = valid_rsc_dat;     // Map valid to uo_out[1]
    assign uo_out[2] = epsilon_triosy_lz; // Map epsilon_triosy to uo_out[2]
    assign uo_out[7:3] = 5'b0;            // Unused outputs set to 0

    // Configure IO enable outputs
    assign uio_oe = 8'b0; // All uio pins are inputs by default

    // Unused IO paths
    assign uio_out = 8'b0; // No output from uio paths

    // Instantiate the monobit module
    monobit monobit_inst (
        .clk(clk),
        .rst(rst_n),
        .is_random_rsc_dat(is_random_rsc_dat),
        .is_random_triosy_lz(is_random_triosy_lz),
        .valid_rsc_dat(valid_rsc_dat),
        .valid_triosy_lz(valid_triosy_lz),
        .epsilon_rsc_dat(epsilon_rsc_dat),
        .epsilon_triosy_lz(epsilon_triosy_lz)
    );

endmodule


//------> /eda/mentor/Siemens_EDA/Catapult_Synthesis_2023.1_2/Mgc_home/pkgs/siflibs/ccs_out_v1.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2015 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a 
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------

module ccs_out_v1 (dat, idat);

  parameter integer rscid = 1;
  parameter integer width = 8;

  output   [width-1:0] dat;
  input    [width-1:0] idat;

  wire     [width-1:0] dat;

  assign dat = idat;

endmodule

//------> /eda/mentor/Siemens_EDA/Catapult_Synthesis_2023.1_2/Mgc_home/pkgs/siflibs/ccs_in_v1.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a 
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------
module ccs_in_v1 (idat, dat);

  parameter integer rscid = 1;
  parameter integer width = 8;

  output [width-1:0] idat;
  input  [width-1:0] dat;

  wire   [width-1:0] idat;

  assign idat = dat;

endmodule

//------> /eda/mentor/Siemens_EDA/Catapult_Synthesis_2023.1_2/Mgc_home/pkgs/siflibs/mgc_io_sync_v2.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a 
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------
module mgc_io_sync_v2 (ld, lz);
    parameter valid = 0;

    input  ld;
    output lz;

    wire   lz;

    assign lz = ld;

endmodule

//------> /eda/mentor/Siemens_EDA/Catapult_Synthesis_2023.1_2/Mgc_home/pkgs/siflibs/mgc_shift_bl_beh_v5.v 
module mgc_shift_bl_v5(a,s,z);
   parameter    width_a = 4;
   parameter    signd_a = 1;
   parameter    width_s = 2;
   parameter    width_z = 8;

   input [width_a-1:0] a;
   input [width_s-1:0] s;
   output [width_z -1:0] z;

   generate if ( signd_a )
   begin: SGNED
     assign z = fshl_s(a,s,a[width_a-1]);
   end
   else
   begin: UNSGNED
     assign z = fshl_s(a,s,1'b0);
   end
   endgenerate

   //Shift-left - unsigned shift argument one bit more
   function [width_z-1:0] fshl_u_1;
      input [width_a  :0] arg1;
      input [width_s-1:0] arg2;
      input sbit;
      parameter olen = width_z;
      parameter ilen = width_a+1;
      parameter len = (ilen >= olen) ? ilen : olen;
      reg [len-1:0] result;
      reg [len-1:0] result_t;
      begin
        result_t = {(len){sbit}};
        result_t[ilen-1:0] = arg1;
        result = result_t <<< arg2;
        fshl_u_1 =  result[olen-1:0];
      end
   endfunction // fshl_u

   //Shift-left - unsigned shift argument
   function [width_z-1:0] fshl_u;
      input [width_a-1:0] arg1;
      input [width_s-1:0] arg2;
      input sbit;
      fshl_u = fshl_u_1({sbit,arg1} ,arg2, sbit);
   endfunction // fshl_u

   //Shift right - unsigned shift argument
   function [width_z-1:0] fshr_u;
      input [width_a-1:0] arg1;
      input [width_s-1:0] arg2;
      input sbit;
      parameter olen = width_z;
      parameter ilen = signd_a ? width_a : width_a+1;
      parameter len = (ilen >= olen) ? ilen : olen;
      reg signed [len-1:0] result;
      reg signed [len-1:0] result_t;
      begin
        result_t = $signed( {(len){sbit}} );
        result_t[width_a-1:0] = arg1;
        result = result_t >>> arg2;
        fshr_u =  result[olen-1:0];
      end
   endfunction // fshl_u

   //Shift left - signed shift argument
   function [width_z-1:0] fshl_s;
      input [width_a-1:0] arg1;
      input [width_s-1:0] arg2;
      input sbit;
      reg [width_a:0] sbit_arg1;
      begin
        // Ignoring the possibility that arg2[width_s-1] could be X
        // because of customer complaints regarding X'es in simulation results
        if ( arg2[width_s-1] == 1'b0 )
        begin
          sbit_arg1[width_a:0] = {(width_a+1){1'b0}};
          fshl_s = fshl_u(arg1, arg2, sbit);
        end
        else
        begin
          sbit_arg1[width_a] = sbit;
          sbit_arg1[width_a-1:0] = arg1;
          fshl_s = fshr_u(sbit_arg1[width_a:1], ~arg2, sbit);
        end
      end
   endfunction

endmodule

//------> /eda/mentor/Siemens_EDA/Catapult_Synthesis_2023.1_2/Mgc_home/pkgs/siflibs/mgc_shift_l_beh_v5.v 
module mgc_shift_l_v5(a,s,z);
   parameter    width_a = 4;
   parameter    signd_a = 1;
   parameter    width_s = 2;
   parameter    width_z = 8;

   input [width_a-1:0] a;
   input [width_s-1:0] s;
   output [width_z -1:0] z;

   generate
   if (signd_a)
   begin: SGNED
      assign z = fshl_u(a,s,a[width_a-1]);
   end
   else
   begin: UNSGNED
      assign z = fshl_u(a,s,1'b0);
   end
   endgenerate

   //Shift-left - unsigned shift argument one bit more
   function [width_z-1:0] fshl_u_1;
      input [width_a  :0] arg1;
      input [width_s-1:0] arg2;
      input sbit;
      parameter olen = width_z;
      parameter ilen = width_a+1;
      parameter len = (ilen >= olen) ? ilen : olen;
      reg [len-1:0] result;
      reg [len-1:0] result_t;
      begin
        result_t = {(len){sbit}};
        result_t[ilen-1:0] = arg1;
        result = result_t <<< arg2;
        fshl_u_1 =  result[olen-1:0];
      end
   endfunction // fshl_u

   //Shift-left - unsigned shift argument
   function [width_z-1:0] fshl_u;
      input [width_a-1:0] arg1;
      input [width_s-1:0] arg2;
      input sbit;
      fshl_u = fshl_u_1({sbit,arg1} ,arg2, sbit);
   endfunction // fshl_u

endmodule

//------> ../td_ccore_solutions/leading_sign_20_0_cece25dae2d00b43c3b124ab661316c967d1_0/rtl.v 
// ----------------------------------------------------------------------
//  HLS HDL:        Verilog Netlister
//  HLS Version:    2023.1_2/1049935 Production Release
//  HLS Date:       Sat Jun 10 10:53:51 PDT 2023
// 
//  Generated by:   lc4976@hansolo.poly.edu
//  Generated date: Fri Mar 29 18:01:13 2024
// ----------------------------------------------------------------------

// 
// ------------------------------------------------------------------
//  Design Unit:    leading_sign_20_0
// ------------------------------------------------------------------


module leading_sign_20_0 (
  mantissa, rtn
);
  input [19:0] mantissa;
  output [4:0] rtn;


  // Interconnect Declarations
  wire ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_6_2_sdt_2;
  wire ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_18_3_sdt_3;
  wire ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_26_2_sdt_2;
  wire ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_42_4_sdt_4;
  wire ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_6_2_sdt_1;
  wire ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_14_2_sdt_1;
  wire ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_26_2_sdt_1;
  wire ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_34_2_sdt_1;
  wire ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_50_2_sdt_1;
  wire c_h_1_2;
  wire c_h_1_5;
  wire c_h_1_6;
  wire c_h_1_8;
  wire ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_and_75_ssc;

  wire ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_and_nl;
  wire ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_or_1_nl;
  wire ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_and_2_nl;
  wire ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leadi000000;

  // Interconnect Declarations for Component Instantiations 
  assign ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_6_2_sdt_2
      = ~((mantissa[17:16]!=2'b00));
  assign ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_6_2_sdt_1
      = ~((mantissa[19:18]!=2'b00));
  assign ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_14_2_sdt_1
      = ~((mantissa[15:14]!=2'b00));
  assign c_h_1_2 = ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_6_2_sdt_1
      & ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_6_2_sdt_2;
  assign ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_18_3_sdt_3
      = (mantissa[13:12]==2'b00) & ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_14_2_sdt_1;
  assign ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_26_2_sdt_2
      = ~((mantissa[9:8]!=2'b00));
  assign ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_26_2_sdt_1
      = ~((mantissa[11:10]!=2'b00));
  assign ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_34_2_sdt_1
      = ~((mantissa[7:6]!=2'b00));
  assign c_h_1_5 = ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_26_2_sdt_1
      & ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_26_2_sdt_2;
  assign c_h_1_6 = c_h_1_2 & ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_18_3_sdt_3;
  assign ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_42_4_sdt_4
      = (mantissa[5:4]==2'b00) & ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_34_2_sdt_1
      & c_h_1_5;
  assign ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_50_2_sdt_1
      = ~((mantissa[3:2]!=2'b00));
  assign c_h_1_8 = c_h_1_6 & ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_42_4_sdt_4;
  assign ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_and_75_ssc
      = (mantissa[1:0]==2'b00) & ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_50_2_sdt_1
      & c_h_1_8;
  assign ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_and_nl
      = c_h_1_6 & (~ ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_42_4_sdt_4);
  assign ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_or_1_nl
      = (c_h_1_2 & (c_h_1_5 | (~ ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_18_3_sdt_3))
      & (~ c_h_1_8)) | ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_and_75_ssc;
  assign ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_and_2_nl
      = ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_6_2_sdt_1
      & (ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_14_2_sdt_1
      | (~ ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_6_2_sdt_2))
      & (~((~(ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_26_2_sdt_1
      & (ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_34_2_sdt_1
      | (~ ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_26_2_sdt_2))))
      & c_h_1_6)) & (ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_wrs_c_50_2_sdt_1
      | (~ c_h_1_8)) & (~ ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_and_75_ssc);
  assign ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leadi000000
      = ~((mantissa[19]) | (~((mantissa[18:17]!=2'b01))) | (((mantissa[15]) | (~((mantissa[14:13]!=2'b01))))
      & c_h_1_2) | ((~((~((mantissa[11]) | (~((mantissa[10:9]!=2'b01))))) & (~(((mantissa[7])
      | (~((mantissa[6:5]!=2'b01)))) & c_h_1_5)))) & c_h_1_6) | (((mantissa[3]) |
      (~((mantissa[2:1]!=2'b01)))) & c_h_1_8) | ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_and_75_ssc);
  assign rtn = {c_h_1_8 , ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_and_nl
      , ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_or_1_nl
      , ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_and_2_nl
      , ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leading_sign_20_0_rtn_ac_math_ac_normalize_20_20_false_AC_TRN_AC_WRAP_leading_1_leadi000000};
endmodule



//------> ./rtl.v 
// ----------------------------------------------------------------------
//  HLS HDL:        Verilog Netlister
//  HLS Version:    2023.1_2/1049935 Production Release
//  HLS Date:       Sat Jun 10 10:53:51 PDT 2023
// 
//  Generated by:   lc4976@hansolo.poly.edu
//  Generated date: Tue Mar 19 12:57:15 2024
// ----------------------------------------------------------------------

// 
// ------------------------------------------------------------------
//  Design Unit:    monobit_core
// ------------------------------------------------------------------


module monobit_core (
  clk, rst_n, is_random_rsc_dat, is_random_triosy_lz, valid_rsc_dat, valid_triosy_lz,
      epsilon_rsc_dat, epsilon_triosy_lz
);
  input clk;
  input rst_n;
  output is_random_rsc_dat;
  output is_random_triosy_lz;
  output valid_rsc_dat;
  output valid_triosy_lz;
  input epsilon_rsc_dat;
  output epsilon_triosy_lz;


  // Interconnect Declarations
  reg is_random_rsci_idat;
  reg valid_rsci_idat;
  wire epsilon_rsci_idat;
  reg reg_epsilon_triosy_obj_ld_cse;
  reg [16:0] sum_sva;
  reg [15:0] bit_count_sva;
  wire [16:0] nl_bit_count_sva;
  wire [16:0] sum_sva_2;
  wire [17:0] nl_sum_sva_2;
  wire unequal_tmp_1;

  wire[15:0] operator_17_true_acc_nl;
  wire[16:0] nl_operator_17_true_acc_nl;
  wire[16:0] operator_17_true_acc_nl_1;
  wire[17:0] nl_operator_17_true_acc_nl_1;

  // Interconnect Declarations for Component Instantiations 
  ccs_out_v1 #(.rscid(32'sd1),
  .width(32'sd1)) is_random_rsci (
      .idat(is_random_rsci_idat),
      .dat(is_random_rsc_dat)
    );
  ccs_out_v1 #(.rscid(32'sd2),
  .width(32'sd1)) valid_rsci (
      .idat(valid_rsci_idat),
      .dat(valid_rsc_dat)
    );
  ccs_in_v1 #(.rscid(32'sd3),
  .width(32'sd1)) epsilon_rsci (
      .dat(epsilon_rsc_dat),
      .idat(epsilon_rsci_idat)
    );
  mgc_io_sync_v2 #(.valid(32'sd0)) is_random_triosy_obj (
      .ld(reg_epsilon_triosy_obj_ld_cse),
      .lz(is_random_triosy_lz)
    );
  mgc_io_sync_v2 #(.valid(32'sd0)) valid_triosy_obj (
      .ld(reg_epsilon_triosy_obj_ld_cse),
      .lz(valid_triosy_lz)
    );
  mgc_io_sync_v2 #(.valid(32'sd0)) epsilon_triosy_obj (
      .ld(reg_epsilon_triosy_obj_ld_cse),
      .lz(epsilon_triosy_lz)
    );
  assign nl_sum_sva_2 = sum_sva + conv_s2s_2_17({(~ epsilon_rsci_idat) , 1'b1});
  assign sum_sva_2 = nl_sum_sva_2[16:0];
  assign unequal_tmp_1 = ~((bit_count_sva==16'b1111111111111111));
  always @(posedge clk) begin
    if ( ~ rst_n ) begin
      reg_epsilon_triosy_obj_ld_cse <= 1'b0;
      valid_rsci_idat <= 1'b0;
      is_random_rsci_idat <= 1'b0;
      bit_count_sva <= 16'b0000000000000000;
      sum_sva <= 17'b00000000000000000;
    end
    else begin
      reg_epsilon_triosy_obj_ld_cse <= 1'b1;
      valid_rsci_idat <= ~ unequal_tmp_1;
      is_random_rsci_idat <= ~((readslicef_16_1_15(operator_17_true_acc_nl)) | (readslicef_17_1_16(operator_17_true_acc_nl_1))
          | unequal_tmp_1);
      bit_count_sva <= nl_bit_count_sva[15:0];
      sum_sva <= sum_sva_2;
    end
  end
  assign nl_operator_17_true_acc_nl = conv_s2u_15_16(~ (sum_sva_2[16:2])) + 16'b0000000010100101;
  assign operator_17_true_acc_nl = nl_operator_17_true_acc_nl[15:0];
  assign nl_operator_17_true_acc_nl_1 = conv_s2u_16_17(sum_sva_2[16:1]) + 17'b00000000101001001;
  assign operator_17_true_acc_nl_1 = nl_operator_17_true_acc_nl_1[16:0];
  assign nl_bit_count_sva  = bit_count_sva + 16'b0000000000000001;

  function automatic [0:0] readslicef_16_1_15;
    input [15:0] vector;
    reg [15:0] tmp;
  begin
    tmp = vector >> 15;
    readslicef_16_1_15 = tmp[0:0];
  end
  endfunction


  function automatic [0:0] readslicef_17_1_16;
    input [16:0] vector;
    reg [16:0] tmp;
  begin
    tmp = vector >> 16;
    readslicef_17_1_16 = tmp[0:0];
  end
  endfunction


  function automatic [16:0] conv_s2s_2_17 ;
    input [1:0]  vector ;
  begin
    conv_s2s_2_17 = {{15{vector[1]}}, vector};
  end
  endfunction


  function automatic [15:0] conv_s2u_15_16 ;
    input [14:0]  vector ;
  begin
    conv_s2u_15_16 = {vector[14], vector};
  end
  endfunction


  function automatic [16:0] conv_s2u_16_17 ;
    input [15:0]  vector ;
  begin
    conv_s2u_16_17 = {vector[15], vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    monobit
// ------------------------------------------------------------------


module monobit (
    input clk,
  input rst_n,
  output is_random_rsc_dat,
  output is_random_triosy_lz,
  output valid_rsc_dat,
  output valid_triosy_lz,
  input epsilon_rsc_dat,
  output epsilon_triosy_lz
);

  // Interconnect Declarations for Component Instantiations 
  monobit_core monobit_core_inst (
      .clk(clk),
      .rst_n(rst_n),
      .is_random_rsc_dat(is_random_rsc_dat),
      .is_random_triosy_lz(is_random_triosy_lz),
      .valid_rsc_dat(valid_rsc_dat),
      .valid_triosy_lz(valid_triosy_lz),
      .epsilon_rsc_dat(epsilon_rsc_dat),
      .epsilon_triosy_lz(epsilon_triosy_lz)
    );
endmodule


// ------------------------------------------------------------------
//  Design Unit:    monobit_block
// ------------------------------------------------------------------


module monobit_block (
  clk, rst_n, is_random_rsc_dat, is_random_triosy_lz, valid_rsc_dat, valid_triosy_lz,
      epsilon_rsc_dat, epsilon_triosy_lz
);
  input clk;
  input rst_n;
  output is_random_rsc_dat;
  output is_random_triosy_lz;
  output valid_rsc_dat;
  output valid_triosy_lz;
  input epsilon_rsc_dat;
  output epsilon_triosy_lz;



  // Interconnect Declarations for Component Instantiations 
  monobit_block_core monobit_block_core_inst (
      .clk(clk),
      .rst_n(rst_n),
      .is_random_rsc_dat(is_random_rsc_dat),
      .is_random_triosy_lz(is_random_triosy_lz),
      .valid_rsc_dat(valid_rsc_dat),
      .valid_triosy_lz(valid_triosy_lz),
      .epsilon_rsc_dat(epsilon_rsc_dat),
      .epsilon_triosy_lz(epsilon_triosy_lz)
    );
endmodule
