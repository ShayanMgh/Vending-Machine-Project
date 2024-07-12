module vending_machine(
    input clk,
    input reset,
    input [3:0] product_select, // P1, P2, P3, P4
    input [3:0] coin_insert,    // 10¢, 20¢, 50¢, $1
    output reg [7:0] lcd_display, // For simplicity, assume 8-bit display
    output reg motor_control,
    output reg [3:0] status_leds  // 4 LEDs for status indication
);

    // State encoding
    typedef enum logic [2:0] {
        IDLE           = 3'b000,
        PRODUCT_SELECTED = 3'b001,
        WAIT_PAYMENT   = 3'b010,
        DISPENSING     = 3'b011,
        ERROR          = 3'b100
    } state_t;

    state_t current_state, next_state;

    // Prices of products
    reg [7:0] prices [3:0];
    initial begin
        prices[0] = 8'd50;  // P1: 50¢
        prices[1] = 8'd75;  // P2: 75¢
        prices[2] = 8'd100; // P3: $1.00
        prices[3] = 8'd150; // P4: $1.50
    end

    // Internal registers
  reg [7:0] total_inserted; //8 bit register for saving total money inserted
  reg [1:0] selected_product;//2 bit register for saving the product that was selected

    // Output logic for LCD display
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            lcd_display <= 8'b0;
        end else begin
            case (current_state)
                IDLE: lcd_display <= 8'b00000001; // Idle message
                PRODUCT_SELECTED: lcd_display <= {4'b0001, selected_product};
                WAIT_PAYMENT: lcd_display <= total_inserted;
                DISPENSING: lcd_display <= 8'b00000010; // Dispensing message
                ERROR: lcd_display <= 8'b00000011; // Error message
            endcase
        end
    end

    // Motor control logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            motor_control <= 0;//if reset is high motor control puts in order to 0
        end else if (current_state == DISPENSING) begin
            motor_control <= 1;/*if current state is dispensing state motor control 
          						puts in order to 1*/
        end else begin
            motor_control <= 0;
        end
    end

    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;//if reset is high current state sets to IDlE
        end else begin
            current_state <= next_state;//else we go to next state
        end
    end

    // Next state logic
  always @(current_state, product_select, coin_insert, total_inserted,/*
  An always block that sets next_state based on the current conditions.
  */
  selected_product, prices[selected_product]) begin
        next_state = current_state;
        case (current_state)
            IDLE: begin //Transition to PRODUCT_SELECTED if product_select is asserted.
                if (product_select) begin
                    next_state = PRODUCT_SELECTED;
                end
            end
            PRODUCT_SELECTED: begin //Transition to WAIT_PAYMENT if coin_insert is asserted.
                if (coin_insert) begin
                    next_state = WAIT_PAYMENT;
                end
            end
          /*
          WAIT_PAYMENT:
			Transition to DISPENSING if total_inserted is greater than or equal to the 				price of the selected product.
				Stay in WAIT_PAYMENT if more coins are inserted.
				Transition to ERROR otherwise.
          */
            WAIT_PAYMENT: begin
                if (total_inserted >= prices[selected_product]) begin
                    next_state = DISPENSING;
                end else if (coin_insert) begin
                    next_state = WAIT_PAYMENT;
                end else begin
                    next_state = ERROR;
                end
            end
            DISPENSING: begin
                next_state = IDLE;
            end
            ERROR: begin
                next_state = IDLE;
            end
        endcase
    end

    // Total inserted logic
    always @(posedge clk or posedge reset) begin
      //If reset is high, total_inserted is set to 0.
        if (reset) begin
            total_inserted <= 0;
          //If coin_insert is asserted, the total_inserted is incremented by the value 				of the inserted coin.
        end else if (coin_insert) begin
            case (coin_insert)
                4'b0001: total_inserted <= total_inserted + 8'd10; // 10¢
                4'b0010: total_inserted <= total_inserted + 8'd20; // 20¢
                4'b0100: total_inserted <= total_inserted + 8'd50; // 50¢
                4'b1000: total_inserted <= total_inserted + 8'd100; // $1
            endcase
        end
    end

    // Selected product logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            selected_product <= 2'b00;
        end else if (product_select) begin
            case (product_select)
                4'b0001: selected_product <= 2'b00; // P1
                4'b0010: selected_product <= 2'b01; // P2
                4'b0100: selected_product <= 2'b10; // P3
                4'b1000: selected_product <= 2'b11; // P4
            endcase
        end
    end
  

    // Status LEDs logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            status_leds <= 4'b0000;
        end else begin
            case (current_state)
                IDLE: status_leds <= 4'b0001;
                PRODUCT_SELECTED: status_leds <= 4'b0010;
                WAIT_PAYMENT: status_leds <= 4'b0100;
                DISPENSING: status_leds <= 4'b1000;
                ERROR: status_leds <= 4'b1111;
            endcase
        end
    end
endmodule
