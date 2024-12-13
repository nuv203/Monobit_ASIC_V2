

/*
 * Copyright (c) 2024 Dennis Du & Rick Gao
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_monobit (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (1=output)
    input  wire       ena,      // always 1 when powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // Monobit signals
  
  wire epsilon_rsc_dat;         // Input bit flow

  wire is_random_rsc_dat;       // Output is random
  wire is_random_triosy_lz;

  wire valid_rsc_dat;           // Output is valid
  wire valid_triosy_lz;
  
  wire epsilon_triosy_lz;


  // use ui_in[0] as epsilon_rsc_dat
  assign epsilon_rsc_dat = ui_in[0];


  monobit monobit_inst (
      .clk                  (clk),
      .rst                  (~rst_n),               // Invert rst_n to rst 
      .is_random_rsc_dat    (is_random_rsc_dat),
      .is_random_triosy_lz  (is_random_triosy_lz),
      .valid_rsc_dat        (valid_rsc_dat),
      .valid_triosy_lz      (valid_triosy_lz),
      .epsilon_rsc_dat      (epsilon_rsc_dat),
      .epsilon_triosy_lz    (epsilon_triosy_lz)
  );

  // output port：monobit result to uo_out
  // Bit 0 - is_random_rsc_dat
  // Bit 1 - valid_rsc_dat
  // Bit 4:2 - Zero
  // Bit 5 - is_random_triosy_lz
  // Bit 6 - valid_triosy_lz
  // Bit 7 - epsilon_triosy_lz
  
  assign uo_out[0] = is_random_rsc_dat;
  assign uo_out[1] = valid_rsc_dat;

  assign uo_out[4:2] = 3'b000;

  assign uo_out[5] = is_random_triosy_lz;
  assign uo_out[6] = valid_triosy_lz;
  assign uo_out[7] = epsilon_triosy_lz;

  

  // NOT USING uio_out and uio_oe
  assign uio_out = 8'b00000000;
  assign uio_oe  = 8'b00000000;

  // list all unused port avoid warning
  wire _unused = &{ena, uio_in, 1'b0};

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


//------> ./rtl.v 
// ----------------------------------------------------------------------
//  HLS HDL:        Verilog Netlister
//  HLS Version:    2023.1_2/1049935 Production Release
//  HLS Date:       Sat Jun 10 10:53:51 PDT 2023
// 
//  Generated by:   rg4238@hansolo.poly.edu
//  Generated date: Tue Dec 10 15:41:04 2024
// ----------------------------------------------------------------------

// 
// ------------------------------------------------------------------
//  Design Unit:    monobit_core_core_fsm
//  FSM Module
// ------------------------------------------------------------------


module monobit_core_core_fsm (
  clk, rst, fsm_output
);
  input clk;
  input rst;
  output [4:0] fsm_output;
  reg [4:0] fsm_output;


  // FSM State Type Declaration for monobit_core_core_fsm_1
  parameter
    main_C_0 = 3'd0,
    main_C_1 = 3'd1,
    main_C_2 = 3'd2,
    main_C_3 = 3'd3,
    main_C_4 = 3'd4;

  reg [2:0] state_var;
  reg [2:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : monobit_core_core_fsm_1
    case (state_var)
      main_C_1 : begin
        fsm_output = 5'b00010;
        state_var_NS = main_C_2;
      end
      main_C_2 : begin
        fsm_output = 5'b00100;
        state_var_NS = main_C_3;
      end
      main_C_3 : begin
        fsm_output = 5'b01000;
        state_var_NS = main_C_4;
      end
      main_C_4 : begin
        fsm_output = 5'b10000;
        state_var_NS = main_C_0;
      end
      // main_C_0
      default : begin
        fsm_output = 5'b00001;
        state_var_NS = main_C_1;
      end
    endcase
  end

  always @(posedge clk) begin
    if ( rst ) begin
      state_var <= main_C_0;
    end
    else begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    monobit_core
// ------------------------------------------------------------------


module monobit_core (
  clk, rst, is_random_rsc_dat, is_random_triosy_lz, valid_rsc_dat, valid_triosy_lz,
      epsilon_rsc_dat, epsilon_triosy_lz
);
  input clk;
  input rst;
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
  wire [4:0] fsm_output;
  reg [6:0] bit_count_sva;
  wire [7:0] nl_bit_count_sva;
  reg reg_epsilon_triosy_obj_ld_cse;
  reg [7:0] sum_sva;
  wire [7:0] sum_sva_2;
  wire [8:0] nl_sum_sva_2;
  wire unequal_tmp_1;

  wire[7:0] operator_8_true_acc_nl;
  wire[8:0] nl_operator_8_true_acc_nl;
  wire[6:0] operator_8_true_acc_nl_1;
  wire[7:0] nl_operator_8_true_acc_nl_1;

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
  monobit_core_core_fsm monobit_core_core_fsm_inst (
      .clk(clk),
      .rst(rst),
      .fsm_output(fsm_output)
    );
  assign nl_sum_sva_2 = sum_sva + conv_s2s_2_8({(~ epsilon_rsci_idat) , 1'b1});
  assign sum_sva_2 = nl_sum_sva_2[7:0];
  assign unequal_tmp_1 = ~((bit_count_sva==7'b1111111));
  always @(posedge clk) begin
    if ( rst ) begin
      valid_rsci_idat <= 1'b0;
    end
    else if ( fsm_output[0] ) begin
      valid_rsci_idat <= ~ unequal_tmp_1;
    end
  end
  // check 29
  always @(posedge clk) begin
    if ( rst ) begin
      is_random_rsci_idat <= 1'b0;
    end
    else if ( fsm_output[0] ) begin
      is_random_rsci_idat <= ~((readslicef_8_1_7(operator_8_true_acc_nl)) | (readslicef_7_1_6(operator_8_true_acc_nl_1))
          | unequal_tmp_1);
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      reg_epsilon_triosy_obj_ld_cse <= 1'b0;
    end
    else begin
      reg_epsilon_triosy_obj_ld_cse <= fsm_output[0];
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      bit_count_sva <= 7'b0000000;
    end
    else if ( fsm_output[0] ) begin
      bit_count_sva <= nl_bit_count_sva[6:0];
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      sum_sva <= 8'b00000000;
    end
    else if ( fsm_output[0] ) begin
      sum_sva <= MUX_v_8_2_2(8'b00000000, sum_sva_2, unequal_tmp_1);
    end
  end
  assign nl_operator_8_true_acc_nl = conv_s2u_7_8(~ (sum_sva_2[7:1])) + 8'b00001111;
  assign operator_8_true_acc_nl = nl_operator_8_true_acc_nl[7:0];
  assign nl_operator_8_true_acc_nl_1 = conv_s2u_6_7(sum_sva_2[7:2]) + 7'b0000111;
  assign operator_8_true_acc_nl_1 = nl_operator_8_true_acc_nl_1[6:0];
  assign nl_bit_count_sva  = bit_count_sva + 7'b0000001;

  function automatic [7:0] MUX_v_8_2_2;
    input [7:0] input_0;
    input [7:0] input_1;
    input  sel;
    reg [7:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_8_2_2 = result;
  end
  endfunction


  function automatic [0:0] readslicef_7_1_6;
    input [6:0] vector;
    reg [6:0] tmp;
  begin
    tmp = vector >> 6;
    readslicef_7_1_6 = tmp[0:0];
  end
  endfunction


  function automatic [0:0] readslicef_8_1_7;
    input [7:0] vector;
    reg [7:0] tmp;
  begin
    tmp = vector >> 7;
    readslicef_8_1_7 = tmp[0:0];
  end
  endfunction


  function automatic [7:0] conv_s2s_2_8 ;
    input [1:0]  vector ;
  begin
    conv_s2s_2_8 = {{6{vector[1]}}, vector};
  end
  endfunction


  function automatic [6:0] conv_s2u_6_7 ;
    input [5:0]  vector ;
  begin
    conv_s2u_6_7 = {vector[5], vector};
  end
  endfunction


  function automatic [7:0] conv_s2u_7_8 ;
    input [6:0]  vector ;
  begin
    conv_s2u_7_8 = {vector[6], vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    monobit
// ------------------------------------------------------------------


module monobit (
  clk, rst, is_random_rsc_dat, is_random_triosy_lz, valid_rsc_dat, valid_triosy_lz,
      epsilon_rsc_dat, epsilon_triosy_lz
);
  input clk;
  input rst;
  output is_random_rsc_dat;
  output is_random_triosy_lz;
  output valid_rsc_dat;
  output valid_triosy_lz;
  input epsilon_rsc_dat;
  output epsilon_triosy_lz;



  // Interconnect Declarations for Component Instantiations 
  monobit_core monobit_core_inst (
      .clk(clk),
      .rst(rst),
      .is_random_rsc_dat(is_random_rsc_dat),
      .is_random_triosy_lz(is_random_triosy_lz),
      .valid_rsc_dat(valid_rsc_dat),
      .valid_triosy_lz(valid_triosy_lz),
      .epsilon_rsc_dat(epsilon_rsc_dat),
      .epsilon_triosy_lz(epsilon_triosy_lz)
    );
endmodule


