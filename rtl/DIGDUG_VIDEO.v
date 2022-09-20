//------------------------------------------------------------------------------
// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileType: SOURCE
// SPDX-FileCopyrightText: (c) 2017 MiSTer-X
//------------------------------------------------------------------------------
// FPGA DigDug (Video part)
//------------------------------------------------------------------------------

`timescale 1 ps / 1 ps

module DIGDUG_VIDEO
    (
        input          CLK48M,
        input   [8:0]  POSH,
        input   [8:0]  POSV,

        input   [1:0]  BG_SELECT,
        input   [1:0]  BG_COLBNK,
        input          BG_CUTOFF,
        input          FG_CLMODE,

        output         FGSCCL,
        output  [9:0]  FGSCAD,
        input   [7:0]  FGSCDT,

        output         SPATCL,
        output  [6:0]  SPATAD,
        input  [23:0]  SPATDT,

        output         VBLK,
        output         PCLK,
        input          iPCLK,
        output  [7:0]  POUT,

        input          V_FLIP,

        input          ROMCL,    // Downloaded ROM image
        input  [15:0]  ROMAD,
        input   [7:0]  ROMDT,
        input          ROMEN
    );

    //---------------------------------------
    //  Clock Generator
    //---------------------------------------
    reg [2:0] clkdiv;
    always @( posedge CLK48M ) clkdiv <= clkdiv+1'b1;
    wire VCLKx8 = CLK48M;
    //wire VCLKx4 = clkdiv[0];
    wire VCLKx2 = clkdiv[1];
`ifdef DISABLE_VCLK_DIVIDER
    wire VCLK   = iPCLK;
`else
    wire VCLK   = clkdiv[2];
`endif
    

    //---------------------------------------
    //  Local Offset
    //---------------------------------------
    reg [8:0] PH, PV;
    reg [8:0] SPH, SPV;
    always@( posedge VCLK ) begin
        PH <= V_FLIP ? (9'd286 - POSH) : POSH + 9'd1;
        PV <= V_FLIP ? (9'd223 - POSV) : POSV+(POSH>=9'd504);
        SPH <= POSH;
        SPV <= POSV+(POSH>=9'd504);
    end

    //---------------------------------------
    //  VRAM Scan Address Generator
    //---------------------------------------
    wire  [5:0] SCOL = PH[8:3]-2'd2;
    wire  [5:0] SROW = PV[8:3]+2'd2;
    wire  [9:0] VSAD = SCOL[5] ? {SCOL[4:0],SROW[4:0]} : {SROW[4:0],SCOL[4:0]};


    //---------------------------------------
    //  Sprite ScanLine Generator
    //---------------------------------------
    wire  [4:0]    SPCOL;

    DIGDUG_SPRITE
        sprite
        (
            .RCLK(VCLKx8),
            .VCLK(VCLK),
            .VCLKx2(VCLKx2),
            .POSH(SPH),
            .POSV(SPV),
            .SPATCL(SPATCL),
            .SPATAD(SPATAD),
            .SPATDT(SPATDT),

            .SPCOL(SPCOL),
            .V_FLIP(V_FLIP),
            .ROMCL(ROMCL),
            .ROMAD(ROMAD),
            .ROMDT(ROMDT),
            .ROMEN(ROMEN)
        );


    //---------------------------------------
    //  FG ScanLine Generator
    //---------------------------------------

    assign        FGSCCL = VCLKx2;
    assign        FGSCAD = VSAD;

    reg   [4:0]   FGCOL;
    wire [10:0]   FGCHAD = {1'b0,FGSCDT[6:0],PV[2:0]};
    wire  [7:0]   FGCHDT;
    DLROM #(11,8) fgchip(~VCLKx2,FGCHAD,FGCHDT, ROMCL,ROMAD[10:0],ROMDT,ROMEN & (ROMAD[15:11]=={4'hD,1'b0}));
    wire  [7:0]   FGCHPX = FGCHDT >> (PH[2:0]);

    wire  [3:0]   FGCLUT = FG_CLMODE ? FGSCDT[3:0] : ({FGSCDT[7:5],1'b0}|{2'b00,FGSCDT[4],1'b0});
    always @( posedge VCLKx2 ) FGCOL <= {FGCHPX[0],FGCLUT};


    //---------------------------------------
    //  BG ScanLine Generator
    //---------------------------------------
    wire  [3:0] BGCOL;

    wire [11:0] BGSCAD = {BG_SELECT,VSAD};
    wire  [7:0] BGSCDT;
    DLROM #(12,8) bgscrn(VCLKx2,BGSCAD,BGSCDT, ROMCL,ROMAD[11:0],ROMDT,ROMEN & (ROMAD[15:12]==4'hB));

    wire [11:0] BGCHAD = {BGSCDT,~PH[2],PV[2:0]};
    wire  [7:0] BGCHDT;
    DLROM #(12,8) bgchip(~VCLKx2,BGCHAD,BGCHDT, ROMCL,ROMAD[11:0],ROMDT,ROMEN & (ROMAD[15:12]==4'hC));
    wire  [7:0] BGCHPI = BGCHDT << (PH[1:0]);
    wire  [1:0] BGCHPX = {BGCHPI[7],BGCHPI[3]};

    wire  [7:0] BGCLAD = BG_CUTOFF ? {6'h0F,BGCHPX} : {BG_COLBNK,BGSCDT[7:4],BGCHPX};
    DLROM #(8,4) bgclut(VCLKx2,BGCLAD,BGCOL, ROMCL,ROMAD[7:0],ROMDT[3:0],ROMEN & (ROMAD[15:8]==8'hDA));


    //---------------------------------------
    //  Color Mixer & Pixel Output
    //---------------------------------------
    wire [4:0] CMIX = SPCOL[4] ? {1'b1,SPCOL[3:0]} : FGCOL[4] ? {1'b0,FGCOL[3:0]} : {1'b0,BGCOL};

    DLROM #(5,8) palet( VCLK, CMIX, POUT, ROMCL,ROMAD[4:0],ROMDT,ROMEN & (ROMAD[15:5]=={8'hDB,3'b000}) );
    assign PCLK = ~VCLK;
    assign VBLK = (PH<9'd64)&(PV==9'd224);

endmodule

