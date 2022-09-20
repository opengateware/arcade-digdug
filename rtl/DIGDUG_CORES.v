//------------------------------------------------------------------------------
// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileType: SOURCE
// SPDX-FileCopyrightText: (c) 2017 MiSTer-X
//------------------------------------------------------------------------------
// FPGA DigDug (CPU part)
//------------------------------------------------------------------------------

`timescale 1 ps / 1 ps

module DIGDUG_CORES
    (
        input         MCLK,    //! Clock (48.0MHz)

        input  [2:0]  RSTS,    //! RESET [2:0]
        input  [2:0]  IRQS,    //!   IRQ [2:0]
        input  [2:0]  NMIS,    //!   NMI [2:0]

        output        DEV_CL,  //! I/O device Interface
        output [15:0] DEV_AD,
        output        DEV_RD,
        input         DEV_DV,
        input  [7:0]  DEV_DO,
        output        DEV_WR,
        output [7:0]  DEV_DI,


        input         ROMCL,   //! Downloaded ROM image
        input  [15:0] ROMAD,
        input  [7:0]  ROMDT,
        input         ROMEN,

        input         PAUSE
    );

    //-----------------------------------------------
    //  CPU0
    //-----------------------------------------------
    wire        CPU0CL;
    wire [15:0] CPU0AD;
    wire        CPU0RD;
    wire        CPU0DV;
    wire  [7:0] CPU0DI;
    wire        CPU0WR;
    wire  [7:0] CPU0DO;

    wire  [7:0] CPU0IR;
    DLROM #(14,8) rom0( DEV_CL, CPU0AD[13:0], CPU0IR, ROMCL,ROMAD[13:0],ROMDT,ROMEN & (ROMAD[15:14]==2'b00) );

    wire NMI0;
    CPUNMIACK n0( RSTS[0], CPU0CL, CPU0AD, NMIS[0], NMI0 );

    CPUCORE cpu0
            (
                .RESET(RSTS[0]),
                .CLK(CPU0CL),
                .IRQ(IRQS[0]),
                .NMI(NMI0),
                .AD(CPU0AD),
                .IR(CPU0IR),
                .RD(CPU0RD),
                .DV(CPU0DV),
                .DI(CPU0DI),
                .WR(CPU0WR),
                .DO(CPU0DO),
                .PAUSE(PAUSE)
            );


    //-----------------------------------------------
    //  CPU1
    //-----------------------------------------------
    wire        CPU1CL;
    wire [15:0] CPU1AD;
    wire        CPU1RD;
    wire        CPU1DV;
    wire  [7:0] CPU1DI;
    wire        CPU1WR;
    wire  [7:0] CPU1DO;

    wire  [7:0] CPU1IR;
    DLROM #(13,8) rom1( DEV_CL, CPU1AD[12:0], CPU1IR, ROMCL,ROMAD[12:0],ROMDT,ROMEN & (ROMAD[15:13]==3'b100) );

    CPUCORE cpu1
            (
                .RESET(RSTS[1]),
                .CLK(CPU1CL),
                .IRQ(IRQS[1]),
                .NMI(NMIS[1]),
                .AD(CPU1AD),
                .IR(CPU1IR),
                .RD(CPU1RD),
                .DV(CPU1DV),
                .DI(CPU1DI),
                .WR(CPU1WR),
                .DO(CPU1DO),
                .PAUSE(PAUSE)
            );


    //-----------------------------------------------
    //  CPU2
    //-----------------------------------------------
    wire        CPU2CL;
    wire [15:0] CPU2AD;
    wire        CPU2RD;
    wire        CPU2DV;
    wire  [7:0] CPU2DI;
    wire        CPU2WR;
    wire  [7:0] CPU2DO;

    wire  [7:0] CPU2IR;
    DLROM #(12,8) rom2( DEV_CL, CPU2AD[11:0], CPU2IR, ROMCL,ROMAD[11:0],ROMDT,ROMEN & (ROMAD[15:12]==4'hA) );

    wire NMI2;
    CPUNMIACK n2( RSTS[2], CPU2CL, CPU2AD, NMIS[2], NMI2 );

    CPUCORE cpu2
            (
                .RESET(RSTS[2]),
                .CLK(CPU2CL),
                .IRQ(IRQS[2]),
                .NMI(NMI2),
                .AD(CPU2AD),
                .IR(CPU2IR),
                .RD(CPU2RD),
                .DV(CPU2DV),
                .DI(CPU2DI),
                .WR(CPU2WR),
                .DO(CPU2DO),
                .PAUSE()
            );


    //-----------------------------------------------
    //  CPU Access Arbiter
    //-----------------------------------------------
    CPUARB arb
           (
               MCLK,
               DEV_CL, DEV_AD, DEV_RD, DEV_DV, DEV_DO, DEV_WR, DEV_DI,
               CPU0CL, CPU0AD, CPU0RD, CPU0DV, CPU0DI, CPU0WR, CPU0DO,
               CPU1CL, CPU1AD, CPU1RD, CPU1DV, CPU1DI, CPU1WR, CPU1DO,
               CPU2CL, CPU2AD, CPU2RD, CPU2DV, CPU2DI, CPU2WR, CPU2DO
           );

endmodule


module CPUARB
    (
        input         CLK48M,

        output        DEV_CL,
        output [15:0] DEV_AD,
        output        DEV_RD,
        input         DEV_DV,
        input  [7:0]  DEV_DO,
        output        DEV_WR,
        output [7:0]  DEV_DI,

        output        CPU0CL,
        input  [15:0] CPU0AD,
        input         CPU0RD,
        output        CPU0DV,
        output [7:0]  CPU0DI,
        input         CPU0WR,
        input  [7:0]  CPU0DO,

        output        CPU1CL,
        input  [15:0] CPU1AD,
        input         CPU1RD,
        output        CPU1DV,
        output [7:0]  CPU1DI,
        input         CPU1WR,
        input  [7:0]  CPU1DO,

        output        CPU2CL,
        input  [15:0] CPU2AD,
        input         CPU2RD,
        output        CPU2DV,
        output [7:0]  CPU2DI,
        input         CPU2WR,
        input  [7:0]  CPU2DO
    );

    reg [1:0] clkdiv;
    always @( posedge CLK48M ) clkdiv <= clkdiv+1'b1;
    wire CLK24M = clkdiv[0];
    wire CLK12M = clkdiv[1];

    reg [3:0] CLKS = 4'b1000;
    reg [3:0] BUSS = 4'b0001;
    always @( posedge CLK12M ) CLKS <= {CLKS[2:0],CLKS[3]};
    always @( negedge CLK12M ) BUSS <= {BUSS[2:0],BUSS[3]};

    assign CPU0CL = CLKS[0];
    assign CPU1CL = CLKS[1];
    assign CPU2CL = CLKS[2];

    assign DEV_CL = CLK24M;

    assign DEV_AD = BUSS[0] ? CPU0AD :
           BUSS[1] ? CPU1AD :
           BUSS[2] ? CPU2AD : 16'd0000;

    assign DEV_RD = BUSS[0] ? CPU0RD :
           BUSS[1] ? CPU1RD :
           BUSS[2] ? CPU2RD : 1'b0;

    assign CPU0DV = BUSS[0] ? DEV_DV : 1'b0;
    assign CPU1DV = BUSS[1] ? DEV_DV : 1'b0;
    assign CPU2DV = BUSS[2] ? DEV_DV : 1'b0;

    assign CPU0DI = BUSS[0] ? DEV_DO : 8'h00;
    assign CPU1DI = BUSS[1] ? DEV_DO : 8'h00;
    assign CPU2DI = BUSS[2] ? DEV_DO : 8'h00;

    assign DEV_WR = BUSS[0] ? CPU0WR :
           BUSS[1] ? CPU1WR :
           BUSS[2] ? CPU2WR : 1'b0;

    assign DEV_DI = BUSS[0] ? CPU0DO :
           BUSS[1] ? CPU1DO :
           BUSS[2] ? CPU2DO : 8'h00;

endmodule

