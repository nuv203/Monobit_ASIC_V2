`define default_netname none

module ccs_out_v1 (dat, idat);
  parameter integer rscid = 1;
  parameter integer width = 8;
  output   [width-1:0] dat;
  input    [width-1:0] idat;
  wire     [width-1:0] dat;
  assign dat = idat;
endmodule

module ccs_in_v1 (idat, dat);
  parameter integer rscid = 1;
  parameter integer width = 8;
  output [width-1:0] idat;
  input  [width-1:0] dat;
  wire   [width-1:0] idat;
  assign idat = dat;
endmodule

module mgc_io_sync_v2 (ld, lz);
    parameter valid = 0;
    input  ld;
    output lz;
    wire   lz;
    assign lz = ld;
endmodule

module monobit_core_core_fsm (
  clk, rst, fsm_output
);
  input clk;
  input rst;
  output [2:0] fsm_output;
  reg [2:0] fsm_output;
  parameter
    main_C_0 = 2'd0,
    main_C_1 = 2'd1,
    main_C_2 = 2'd2;
  reg [1:0] state_var;
  reg [1:0] state_var_NS;
  always @(*)
  begin
    case (state_var)
      main_C_1 : begin
        fsm_output = 3'b010;
        state_var_NS = main_C_2;
      end
      main_C_2 : begin
        fsm_output = 3'b100;
        state_var_NS = main_C_0;
      end
      default : begin
        fsm_output = 3'b001;
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
  reg is_random_rsci_idat;
  reg valid_rsci_idat;
  wire epsilon_rsci_idat;
  wire [2:0] fsm_output;
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
  ccs_out_v1 #(.rscid(1), .width(1)) is_random_rsci (
      .idat(is_random_rsci_idat),
      .dat(is_random_rsc_dat)
    );
  ccs_out_v1 #(.rscid(2), .width(1)) valid_rsci (
      .idat(valid_rsci_idat),
      .dat(valid_rsc_dat)
    );
  ccs_in_v1 #(.rscid(3), .width(1)) epsilon_rsci (
      .dat(epsilon_rsc_dat),
      .idat(epsilon_rsci_idat)
    );
  mgc_io_sync_v2 #(.valid(0)) is_random_triosy_obj (
      .ld(reg_epsilon_triosy_obj_ld_cse),
      .lz(is_random_triosy_lz)
    );
  mgc_io_sync_v2 #(.valid(0)) valid_triosy_obj (
      .ld(reg_epsilon_triosy_obj_ld_cse),
      .lz(valid_triosy_lz)
    );
  mgc_io_sync_v2 #(.valid(0)) epsilon_triosy_obj (
      .ld(reg_epsilon_triosy_obj_ld_cse),
      .lz(epsilon_triosy_lz)
    );
  monobit_core_core_fsm monobit_core_core_fsm_inst (
      .clk(clk),
      .rst(rst),
      .fsm_output(fsm_output)
    );
  assign nl_sum_sva_2 = sum_sva + {{6{~epsilon_rsci_idat}}, 1'b1};
  assign sum_sva_2 = nl_sum_sva_2[7:0];
  assign unequal_tmp_1 = ~(bit_count_sva == 7'b1111111);
  always @(posedge clk) begin
    if ( rst ) begin
      valid_rsci_idat <= 1'b0;
    end
    else if ( fsm_output[0] ) begin
      valid_rsci_idat <= ~unequal_tmp_1;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      is_random_rsci_idat <= 1'b0;
    end
    else if ( fsm_output[0] ) begin
      is_random_rsci_idat <= ~((~|sum_sva_2[7:1]) | (~|sum_sva_2[7:2]) | unequal_tmp_1);
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
      sum_sva <= unequal_tmp_1 ? sum_sva_2 : 8'b00000000;
    end
  end
  assign nl_bit_count_sva  = bit_count_sva + 7'b0000001;
endmodule

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

module tt_um_monobit (
    input  wire [7:0] ui_in,    
    output wire [7:0] uo_out,   
    input  wire [7:0] uio_in,   
    output wire [7:0] uio_out,  
    output wire [7:0] uio_oe,   
    input  wire       ena,      
    input  wire       clk,      
    input  wire       rst_n     
);
    wire is_random;
    wire valid;
    wire epsilon_triosy;

    assign uo_out = {6'b0, valid, is_random};
    assign uio_out = 8'b0;
    assign uio_oe = 8'b0;

    monobit monobit_inst (
        .clk(clk),
        .rst(~rst_n),
        .is_random_rsc_dat(is_random),
        .is_random_triosy_lz(),
        .valid_rsc_dat(valid),
        .valid_triosy_lz(),
        .epsilon_rsc_dat(ui_in[0]),
        .epsilon_triosy_lz(epsilon_triosy)
    );
endmodule
