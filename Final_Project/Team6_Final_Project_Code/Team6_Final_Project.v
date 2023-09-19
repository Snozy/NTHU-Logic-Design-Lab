`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jason, Tuudo
// 
// Create Date: 12/25/2022 11:51:38 PM
// Design Name: 
// Module Name: Crypto
// Project Name: Plinko Game
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: Final project for Logic Design Lab
// 
//////////////////////////////////////////////////////////////////////////////////


module Crypto3_1(clk,rst,track1,track2,track3,track4,track5,anode, cathode,track6,motor_servo);
    //inputs
    input clk;
    input rst;
    //inputs for the sensors
    input track1,track2,track3,track4,track5,track6; 
    output motor_servo;
    //seven segment output
    output [3:0] anode;
    output [6:0] cathode;
    wire [7:0] score_dummy; //score to output
    wire flag; //enable motor
    //variables for reset button 
    wire rst_dp, rst_op; 
    //clock divided variables
    wire clk_d2;//25MHz
    wire clk_d22;
    //clock
    clk_div #(2) CD0(.clk(clk), .clk_d(clk_d2));
	clk_div #(19) CD1(.clk(clk), .clk_d(clk_d22));

    //reset button, one pulse
    debounce DB1(.s(rst), .s_db(rst_db), .clk(clk));
    onepulse OP1(.s(rst_db), .s_op(rst_op), .clk(clk_d22));
    //sensor calculation
    //get input from 5 scoring sensor
    sensor1 SS1(.clk(clk), .rst(rst), .track1(track1), .track2(track2), .track3(track3), .track4(track4), .track5(track5),.score(score_dummy));
    //set motor sensor
    sensor6 SS2(.clk(clk), .rst(rst), .track6(track6), .flag_motor(flag));
    //pass enabler flag to motor
    motor M1 (.mclk(clk) , .flag_m(flag), .servo(motor_servo));
    //output value       (7'd10,7'd20,7'd50)                  
    anodecathode disp0(.score_an(score_dummy), .clk(clk), .rst_n(rst), .anode(anode), .cathode(cathode));
endmodule
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////SCORE////////////////////////////////
////////////////////////////CALCULATION/////////////////////
////////////////////////////////////////////////////////////
module sensor1(clk,rst,track1,track2,track3,track4,track5,score);
    input clk;
    input rst;
    input track1,track2,track3,track4,track5; 

    output reg [7:0]score; 
    //values for FSM
    reg [2:0] state, next_state;
    reg [7:0]next_score;
    wire cclk;
    parameter S1 = 3'b000; //wait for ball
    parameter S2 = 3'b001; // give out score and countdown
    //implement the clock so that we can see well on the fpga display
    clkdiv clk_count1 (.clk(clk), .clk_div(cclk));
    //initialize state values
    always @(posedge cclk)begin
        if(rst)begin
            state <= S1;
            score <= 7'd0; 
        end else begin
            state <= next_state;
            score <= next_score;
        end
    end
    //setup the FSM
    always @(*)begin
        next_state = state;
        next_score = score;
        case(state)
            S1:begin
                //getting inputs from sensed sensor
                //outputing score
                if(!track1 ||!track5)begin
                   next_state = S2; //10 
                   next_score = 7'd10;
                end else if(!track2 || !track4)begin //20
                   next_state = S2;
                   next_score = 7'd20;  // 10100 0000020/10 2 000020%10 0 
                end else if(!track3)begin
                   next_state = S2; //50
                   next_score = 7'd50;  
                end else begin
                    next_score = 7'd0;
                    next_state = S1;
                end
            end
            S2:begin
                //countdown tickets
                if(score > 4'd0)begin
                    next_score = score - 1'd1;
                    next_state = S2; 
                end else begin
                    next_score = 4'd0;
                    next_state = S1;
                end
           end
        endcase
    end
endmodule
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////ANODE////////////////////////////////
////////////////////////////OUTPUT 7 SEGMENT////////////////
////////////////////////////////////////////////////////////
module anodecathode(score_an, clk, rst_n,anode,cathode);
    input [7:0] score_an;
    input clk;
    input rst_n;

    output reg [3:0] anode;
    output [6:0] cathode;

    reg[3:0] digit;
    wire [1:0] clkdisp;

    getcathode gc0(digit, cathode);
    dispclk clk1(clk, clkdisp);    

    always @(*) begin
        case(clkdisp)
        2'b00: begin
            //do not need
            anode = 4'b1111; 
            digit = score_an%10;
        end
        2'b01: begin
            //do not need
            anode = 4'b1111; 
            digit = score_an/10;
        end
        2'b10: begin //1's value
            anode = 4'b1011; 
            digit = score_an%10;
        end
        2'b11: begin //10's value
            anode = 4'b0111; 
            digit = score_an/10;
        end
        endcase
    end 
endmodule
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////CATHODE//////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
module getcathode(digit, cathode);
    input [3:0] digit;
    output reg [6:0] cathode;
    always@(*) begin        
        case(digit)
            4'd0: cathode = 7'b0000001;
            4'd1: cathode = 7'b1001111;
            4'd2: cathode = 7'b0010010;
            4'd3: cathode = 7'b0000110;
            4'd4: cathode = 7'b1001100;
            4'd5: cathode = 7'b0100100;
            4'd6: cathode = 7'b0100000;
            4'd7: cathode = 7'b0001111;
            4'd8: cathode = 7'b0000000;
            4'd9: cathode = 7'b0000100;
            default: cathode = 7'b1111111;
        endcase
    end
endmodule
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////MOTOR////////////////////////////////
////////////////////////////ENABLER/////////////////////////
////////////////////////////////////////////////////////////
module sensor6(clk,rst,track6,flag_motor);
    input clk;
    input rst;
    input track6;
    output reg flag_motor; //motor enabler
    //values for FSM
    reg [3-1:0] state, next_state;
    reg [7:0] count, next_count;
    reg next_flag_motor,next_track;
    
    parameter S1 = 3'b000; 
    parameter S2 = 3'b001; 
    
    always @(posedge clk)begin
        if(rst)begin
            state = S1;
            flag_motor = 1'b0; 
            count = 0;
        end else begin
            count <= next_count;
            state <= next_state;
            flag_motor <= next_flag_motor;
        end
    end
    always @(*)begin
        next_count = count;
        next_state = state;
        next_flag_motor = flag_motor;
        case(state)
            S1:begin
                //if detects coin in the coin machine
                if(!track6)begin
                   next_state = S2;
                   next_flag_motor = 1'b1;
                   next_count = 0;
                end else begin
                    next_state = S1;
                    next_flag_motor = 1'b0;
                    next_count = 0;
                end
            end
            
            S2: begin
                //enable the motor 69 countdown
                if(count >= 69)begin
                    next_state = S1;
                    next_flag_motor = 1'b0;
                    next_count = 0;
                end else if(count < 69) begin
                    next_count = count + 1;
                    next_state = S2;
                    next_flag_motor = 1'b1;
                end
            end
            
        endcase
    end
endmodule
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////MG90S MOTOR//////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
module motor( mclk, flag_m, servo);
    input mclk;
    input flag_m;
    output servo;

    reg [19:0] counter;
    reg servo_reg;
    reg run_servo;
    reg [15:0] control = 0; //65535 there is wiggle room but you should be careful to not overcontrol

    always @(posedge mclk) begin

    //Servo algorithm counter algorithm
        counter <= counter + 1;
        if(counter == 'd999999)begin
                counter <= 0;
        end
        if(counter < ('d50000 + control))begin
                servo_reg <= 1;
        end else begin
                servo_reg <= 0;
        end

    end

    //check if the IR sensor enables the motor
    always@(posedge mclk)begin
        if(flag_m == 1'b1)begin //flag = 1 
            run_servo = servo_reg;
        end
        else begin
            run_servo = 1'b0;
        end
    end
    //tell the motor to run
    assign servo = run_servo;
endmodule
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////BUTTON///////////////////////////////
/////////////////////////////ONEPULSE///////////////////////
/////////////////////////////////////DEBOUNCE///////////////
module onepulse(s, s_op, clk);
	input s, clk;
	output reg s_op;
	reg s_delay;
	always@(posedge clk)begin
		s_op <= s&(!s_delay);
		s_delay <= s;
	end
endmodule

module debounce(s, s_db, clk);
	input s, clk;
	output s_db;
	reg [3:0] DFF;
	
	always@(posedge clk)begin
		DFF[3:1] <= DFF[2:0];
		DFF[0] <= s;
	end
	assign s_db = (DFF == 4'b1111)? 1'b1 : 1'b0;
endmodule
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////CLOCKS///////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
module clk_div #(parameter n = 2)(clk, clk_d);
	input clk;
	output clk_d;
	reg [n-1:0]count;
	wire[n-1:0]next_count;
	
	always@(posedge clk)begin
		count <= next_count;
	end
	
	assign next_count = count + 1;
	assign clk_d = count[n-1];
endmodule

module clkdiv(clk, clk_div);
    input clk;
    output reg clk_div;
    
    reg[23:0] Counter;
    
    always @(posedge clk) Counter <= Counter + 1'b1;
    
    always @(*) clk_div = Counter[23];     
endmodule

module dispclk(clk, out);
    input clk;
    output reg [1:0]out;
    
    reg [30:0]cnt;
    
    always @(posedge clk)begin
        cnt <= cnt + 1'b1;
        out <= cnt[18:17];

    end
endmodule