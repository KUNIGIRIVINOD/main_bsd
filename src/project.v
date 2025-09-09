/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset (active low)
);

  // Internal nets driven by the traffic_light instance
  wire [1:0] main_street;
  wire [1:0] side_street;
  wire       pedestrian_light;

  // Instantiate traffic light module.
  // Note: traffic_light expects active-high reset; rst_n is active-low so invert it.
  traffic_light tl_inst (
    .clk(clk),
    .reset(~rst_n),
    .main_street(main_street),
    .side_street(side_street),
    .pedestrian_light(pedestrian_light)
  );

  // Map outputs into 8-bit uo_out:
  //  uo_out[1:0] = main_street
  //  uo_out[3:2] = side_street
  //  uo_out[4]   = pedestrian_light
  //  uo_out[7:5] = 0
  assign uo_out  = {3'b000, pedestrian_light, side_street, main_street}; // 3+1+2+2 = 8 bits
  assign uio_out = 8'b00000000;
  assign uio_oe  = 8'b00000000;

  // Suppress unused-signal warnings for inputs not used by wrapper
  wire _unused = &{ui_in, uio_in, ena, 1'b0};

endmodule


// Traffic Light Controller FSM (your original logic, unchanged)
module traffic_light (
  input  wire clk,
  input  wire reset,                 // active high reset inside module
  output reg [1:0] main_street,
  output reg [1:0] side_street,
  output reg       pedestrian_light
);

  parameter MAIN_GREEN       = 3'b000;
  parameter MAIN_YELLOW      = 3'b001;
  parameter SIDE_GREEN       = 3'b010;
  parameter SIDE_YELLOW      = 3'b011;
  parameter PEDESTRIAN_CROSS = 3'b100;

  reg [2:0] present_state, next_state;
  reg [1:0] count;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      count <= 0;
      present_state <= MAIN_GREEN;
    end else begin
      present_state <= next_state;
      if (present_state != next_state)
        count <= 0;
      else
        count <= count + 1;
    end
  end

  always @(*) begin
    main_street = 2'b00;
    side_street = 2'b00;
    pedestrian_light = 0;
    next_state = MAIN_GREEN;

    case (present_state)
      MAIN_GREEN: begin
        main_street = 2'b10;
        side_street = 2'b00;
        pedestrian_light = 0;
        if (count == 2'b10)
          next_state = MAIN_YELLOW;
        else
          next_state = MAIN_GREEN;
      end

      MAIN_YELLOW: begin
        main_street = 2'b01;
        side_street = 2'b00;
        pedestrian_light = 0;
        if (count == 2'b10)
          next_state = SIDE_GREEN;
        else
          next_state = MAIN_YELLOW;
      end

      SIDE_GREEN: begin
        main_street = 2'b00;
        side_street = 2'b10;
        pedestrian_light = 0;
        if (count == 2'b10)
          next_state = SIDE_YELLOW;
        else
          next_state = SIDE_GREEN;
      end

      SIDE_YELLOW: begin
        main_street = 2'b00;
        side_street = 2'b01;
        pedestrian_light = 0;
        if (count == 2'b10)
          next_state = PEDESTRIAN_CROSS;
        else
          next_state = SIDE_YELLOW;
      end

      PEDESTRIAN_CROSS: begin
        main_street = 2'b00;
        side_street = 2'b00;
        pedestrian_light = 1;
        if (count == 2'b10)
          next_state = MAIN_GREEN;
        else
          next_state = PEDESTRIAN_CROSS;
      end

      default: begin
        main_street = 2'b00;
        side_street = 2'b00;
        pedestrian_light = 0;
        next_state = MAIN_GREEN;
      end
    endcase
  end
endmodule
