// SPDX-FileCopyrightText: 2023 Russell Friesenhahn
// SPDX-License-Identifier: MIT

`default_nettype none
module spi_peripheral #(
    parameter SPI_WORD_LEN = 16
) (
    input wire Clk,
    input wire Rst,
    input wire SPI_clk,
    input wire SPI_csb,
    input wire SPI_copi,
    output wire SPI_cipo,
    input wire SPI_CPOL,
    input wire SPI_CPHA,
    output reg [SPI_WORD_LEN-1:0] SPI_reg,
    output reg SPI_reg_valid
);

    assign SPI_cipo = SPI_reg[7];
    reg spi_clk_d1;
    reg spi_csb_d1;
    wire spi_clk_rising = SPI_clk & ~spi_clk_d1;
    wire spi_clk_falling = ~SPI_clk & spi_clk_d1;
    wire shift = (spi_clk_rising & ((~SPI_CPOL & ~SPI_CPHA) | (SPI_CPOL & SPI_CPHA))) |
                   (spi_clk_falling & ((SPI_CPOL & ~SPI_CPHA) | (~SPI_CPOL & SPI_CPHA)));

    always @(posedge Clk) begin
        if(Rst) begin
            spi_clk_d1 <= SPI_CPOL;
            spi_csb_d1 <= 1'b1;
        end else begin
            spi_clk_d1 <= SPI_clk;
            spi_csb_d1 <= SPI_csb;
            SPI_reg_valid <= ~spi_csb_d1 & SPI_csb;

            if((SPI_csb == 1'b0) && shift) begin
                SPI_reg <= {SPI_reg[SPI_WORD_LEN-2:0],SPI_copi};
            end
        end
    end
endmodule
`default_nettype wire
