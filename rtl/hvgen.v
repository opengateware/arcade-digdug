//------------------------------------------------------------------------------
// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileType: SOURCE
// SPDX-FileCopyrightText: (c) 2017 MiSTer-X
//------------------------------------------------------------------------------
// FPGA DigDug (Video timing part)
//------------------------------------------------------------------------------

`timescale 1 ps / 1 ps

module hvgen
    (
        input            iPCLK,
        output     [8:0] oHPOS,
        output     [8:0] oVPOS,

        output reg       oHBLK = 1,
        output reg       oVBLK = 1,
        output reg       oHSYN = 1,
        output reg       oVSYN = 1,
        output reg       oBLKN
    );

    reg [8:0] hcnt = 0;
    reg [8:0] vcnt = 0;

    assign oHPOS = hcnt;
    assign oVPOS = vcnt;

    always @(posedge iPCLK) begin
        case (hcnt)
            288: begin oHBLK <= 1; hcnt <= hcnt + 1'b1; end
            311: begin oHSYN <= 0; hcnt <= hcnt + 1'b1; end
            342: begin oHSYN <= 1; hcnt <= 471;         end
            511: begin oHBLK <= 0; hcnt <= 0;
                case (vcnt)
                    223: begin oVBLK <= 1; vcnt <= vcnt + 1'b1; end
                    226: begin oVSYN <= 0; vcnt <= vcnt + 1'b1; end
                    233: begin oVSYN <= 1; vcnt <= 483;         end
                    511: begin oVBLK <= 0; vcnt <= 0;           end
                    default:               vcnt <= vcnt + 1'b1;
                endcase
            end
            default: hcnt <= hcnt + 1'b1;
        endcase
        oBLKN <= ~(oHBLK | oVBLK);
    end

endmodule
