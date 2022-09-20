//------------------------------------------------------------------------------
// SPDX-License-Identifier: MPL-2.0
// SPDX-FileType: SOURCE
// SPDX-FileCopyrightText: (c) 2022 Marcus Andrade
//------------------------------------------------------------------------------
// Generic Gamepad interface for the Analogue Pocket
//------------------------------------------------------------------------------

`timescale 1 ps / 1 ps

module pocket_gamepad
    (
        input        iCLK,
        input [15:0] iJOY,

        output wire  PAD_U,
        output wire  PAD_D,
        output wire  PAD_L,
        output wire  PAD_R,

        output wire  BTN_A,
        output wire  BTN_B,
        output wire  BTN_X,
        output wire  BTN_Y,

        output wire  BTN_L1,
        output wire  BTN_L2,
        output wire  BTN_L3,

        output wire  BTN_R1,
        output wire  BTN_R2,
        output wire  BTN_R3,

        output wire  BTN_SE,
        output wire  BTN_ST
    );

    assign PAD_U  = joy_keys_s[0];
    assign PAD_D  = joy_keys_s[1];
    assign PAD_L  = joy_keys_s[2];
    assign PAD_R  = joy_keys_s[3];

    assign BTN_A  = joy_keys_s[4];
    assign BTN_B  = joy_keys_s[5];
    assign BTN_X  = joy_keys_s[6];
    assign BTN_Y  = joy_keys_s[7];

    assign BTN_L1 = joy_keys_s[8];
    assign BTN_R1 = joy_keys_s[9];

    assign BTN_L2 = joy_keys_s[10];
    assign BTN_R2 = joy_keys_s[11];

    assign BTN_L3 = joy_keys_s[12];
    assign BTN_R3 = joy_keys_s[13];

    assign BTN_SE = joy_keys_s[14];
    assign BTN_ST = joy_keys_s[15];

    reg [15:0] joy_keys_s;

    // Sync Joystick to Core Clock
    always @ (posedge iCLK) begin
        joy_keys_s <= iJOY;
    end

endmodule
