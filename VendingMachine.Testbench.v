module vending_machine_tb;

    reg clk;
    reg reset;
    reg [3:0] product_select;
    reg [3:0] coin_insert;
    wire [7:0] lcd_display;
    wire motor_control;
    wire [3:0] status_leds;

    vending_machine uut (
        .clk(clk),
        .reset(reset),
        .product_select(product_select),
        .coin_insert(coin_insert),
        .lcd_display(lcd_display),
        .motor_control(motor_control),
        .status_leds(status_leds)
    );

    initial begin
        // VCD Dump
        $dumpfile("dump.vcd");
        $dumpvars(0, vending_machine_tb);

        clk = 0;
        reset = 1;
        product_select = 0;
        coin_insert = 0;
        #5 reset = 0;
        #10 product_select = 4'b0001; // Select product P1
        #10 coin_insert = 4'b1000;    // Insert $1 coin
        #10 coin_insert = 0;
        #50; // Wait for dispensing
        #10 product_select = 4'b0010; // Select product P2
        #10 coin_insert = 4'b0100;    // Insert 50¢ coin
        #10 coin_insert = 4'b0010;    // Insert 20¢ coin
        #10 coin_insert = 4'b0001;    // Insert 10¢ coin
        #10 coin_insert = 0;
        #50; // Wait for dispensing
        #10 $finish;
    end

    always #5 clk = ~clk;

endmodule
