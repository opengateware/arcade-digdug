//------------------------------------------------------------------------------
// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileType: SOURCE
// SPDX-FileCopyrightText: (c) 2017 MiSTer-X
//------------------------------------------------------------------------------
// FPGA DigDug (Top module)
//------------------------------------------------------------------------------

`timescale 1 ps / 1 ps

module FPGA_DIGDUG
    (
        input            RESET,  //! RESET
        input            MCLK,   //! Master Clock (48.0MHz) = VCLKx8

        input      [7:0] INP0,   //! Control Panel
        input      [7:0] INP1,
        input      [7:0] DSW0,
        input      [7:0] DSW1,

        input      [8:0] PH,     //! PIXEL H
        input      [8:0] PV,     //! PIXEL V
        input            iPCLK,  //! PIXEL CLOCK [IN] (Don't use Clock Divider / DEFINED VIA VERILOG_MACRO)
        output           oPCLK,  //! PIXEL CLOCK [OUT]
        output     [7:0] POUT,   //! PIXEL OUT

        output reg [7:0] SOUT,   //! SOUND OUT

        output     [7:0] LED,    //! LEDs (for Debug)

        input            V_FLIP, //! Vertical flip video

        input            ROMCL,  //! Downloaded ROM image
        input     [15:0] ROMAD,
        input      [7:0] ROMDT,
        input            ROMEN,

        input            PAUSE,

        input     [10:0] hs_address,
        output     [7:0] hs_data_out,
        input      [7:0] hs_data_in,
        input            hs_write,
        input            hs_access
    );

    // Common I/O Device Bus
    wire        DEV_CL;
    wire [15:0] DEV_AD;
    wire        DEV_RD;
    wire        DEV_DV;
    wire  [7:0] DEV_DO;
    wire        DEV_WR;
    wire  [7:0] DEV_DI;


    //-----------------------------------------------
    //  CPUs
    //-----------------------------------------------
    wire    [2:0]    RSTS,IRQS,NMIS;

    DIGDUG_CORES cores
                 (
                     .MCLK(MCLK),
                     .RSTS(RSTS),.IRQS(IRQS),.NMIS(NMIS),

                     .DEV_CL(DEV_CL),.DEV_AD(DEV_AD),
                     .DEV_RD(DEV_RD),.DEV_DV(DEV_DV),.DEV_DO(DEV_DO),
                     .DEV_WR(DEV_WR),.DEV_DI(DEV_DI),

                     .ROMCL(ROMCL),.ROMAD(ROMAD),.ROMDT(ROMDT),.ROMEN(ROMEN),

                     .PAUSE(PAUSE)
                 );

    assign LED = { RSTS, IRQS[1:0], 1'b0, NMIS[2],NMIS[0] };


    //-----------------------------------------------
    //  Sound wave ROM
    //-----------------------------------------------
    wire        WAVECL;
    wire [7:0]  WAVEAD;
    wire [3:0]  WAVEDT;

    DLROM #(8,4) wave(WAVECL,WAVEAD,WAVEDT, ROMCL,ROMAD[7:0],ROMDT[3:0],ROMEN & (ROMAD[15:8]==8'hD8));


    //-----------------------------------------------
    //  Common I/O Device Module
    //-----------------------------------------------
    wire        PCMCLK;
    wire [7:0]  PCMOUT;
    always @(posedge PCMCLK) SOUT <= PCMOUT;

    wire        FGSCCL;
    wire [9:0]  FGSCAD;
    wire [7:0]  FGSCDT;

    wire        SPATCL;
    wire [6:0]  SPATAD;
    wire [23:0] SPATDT;

    wire [1:0]  BG_SELECT;
    wire [1:0]  BG_COLBNK;
    wire        BG_CUTOFF;
    wire        FG_CLMODE;

    wire        VBLK;

    DIGDUG_IODEV iodev
                 (
                     .RESET(RESET),
                     .VBLK(VBLK),

                     .INP0(INP0),
                     .INP1(INP1),
                     .DSW0(DSW0),
                     .DSW1(DSW1),

                     .CL(DEV_CL), // Access Clock: 24.0MHz
                     .AD(DEV_AD),.WR(DEV_WR),.DI(DEV_DI),
                     .RD(DEV_RD),.DV(DEV_DV),.DO(DEV_DO),

                     .RSTS(RSTS),.IRQS(IRQS),.NMIS(NMIS),

                     .CLK48M(MCLK),.PCMCLK(PCMCLK),.PCMOUT(PCMOUT),

                     .WAVECL(WAVECL),.WAVEAD(WAVEAD),.WAVEDT(WAVEDT),

                     .FGSCCL(FGSCCL),.FGSCAD(FGSCAD),.FGSCDT(FGSCDT),
                     .SPATCL(SPATCL),.SPATAD(SPATAD),.SPATDT(SPATDT),

                     .BG_SELECT(BG_SELECT),.BG_COLBNK(BG_COLBNK),.BG_CUTOFF(BG_CUTOFF),
                     .FG_CLMODE(FG_CLMODE),

                     .hs_address(hs_address),
                     .hs_data_in(hs_data_in),
                     .hs_data_out(hs_data_out),
                     .hs_write(hs_write),
                     .hs_access(hs_access)
                 );


    //-----------------------------------------------
    //  Video Module
    //-----------------------------------------------
    DIGDUG_VIDEO video
                 (
                     .CLK48M(MCLK),
                     .POSH(PH),.POSV(PV),

                     .BG_SELECT(BG_SELECT),.BG_COLBNK(BG_COLBNK),.BG_CUTOFF(BG_CUTOFF),
                     .FG_CLMODE(FG_CLMODE),

                     .FGSCCL(FGSCCL),.FGSCAD(FGSCAD),.FGSCDT(FGSCDT),
                     .SPATCL(SPATCL),.SPATAD(SPATAD),.SPATDT(SPATDT),

                     .VBLK(VBLK),.iPCLK(iPCLK),.PCLK(oPCLK),.POUT(POUT),

                     .V_FLIP(V_FLIP),

                     .ROMCL(ROMCL),.ROMAD(ROMAD),.ROMDT(ROMDT),.ROMEN(ROMEN)
                 );


endmodule

