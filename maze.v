`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:05:07 11/30/2021 
// Design Name: 
// Module Name:    maze 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module maze(
				 clk,
				 starting_col,
				 starting_row,
				 maze_in,
				 row, col,
				 maze_oe,
				 maze_we,
				 done
				);
 
parameter maze_width = 6;

//starile automatului		 
`define stare_initiala          0
`define directie_posibila       1
`define plecare_din_start       2
`define perete_fata             3
`define perete_stanga           4
`define ultima_incercare        5
		
//directie
`define RIGHT  					  0
`define LEFT                    1
`define UP                      2
`define DOWN                    3
	

input                           clk;
input      [maze_width - 1 : 0] starting_col, starting_row;
input                           maze_in;
output reg [maze_width - 1 : 0] row, col;
output reg                      maze_oe;
output reg                      maze_we;
output reg                      done;
		 
		 
reg [2 : 0]              state = 0, next_state = 0;
reg [maze_width - 1 : 0] row_curent, col_curent; // variabile in care pastrez coordonatele curente
reg [1 : 0]              directie;//variabila pentru stabilirea directiei

//partea secventiala 
	always @(posedge clk) begin
		if(done == 0) begin
			state <= next_state;
		end	
	end

//partea combinationala
	always @(*) begin
			case(state)
				`stare_initiala: begin
					directie = `DOWN;//presupun ca directia initiala va fi in jos
					row_curent = starting_row;
					col_curent = starting_col;
					row = row_curent;
					col = col_curent;
					done = 0;
					maze_oe = 0;
					maze_we = 1; //marchez si merg mai departe	
					next_state = `directie_posibila;
				end
				
				`directie_posibila: begin
					row = row_curent;
					col = col_curent;
					if(row == 0 || row == 63 || col == 0 ||col == 63)begin // sunt pe margine
						done = 1;
						maze_we = 1;
						maze_oe = 0;
					end
					//privesc spre peretele din dreapta
					else if(directie == `RIGHT) begin
						row = row_curent + 1; 
					end
					else if(directie == `LEFT)begin
						row = row_curent - 1;
					end
					else if(directie == `UP)begin
						col = col_curent + 1;
					end
					else if(directie == `DOWN) begin
						col = col_curent - 1;
					end
					if (done == 0)begin
					maze_oe = 1;//transmit coordonatele din dreapta pentru a vedea daca e liber sau nu
					maze_we = 0;
					next_state = `plecare_din_start;
					end				
				end
				
				`plecare_din_start: begin
					row = row_curent;
					col = col_curent;
					if(maze_in == 0)begin // peretele din dreapta e liber
					//mai intai imi rotesc pozitia spre dreapta
						if(directie == `RIGHT)begin
							directie = `DOWN; 
						end
						else if(directie == `UP)begin
							directie = `RIGHT;
						end
						else if(directie == `LEFT)begin
							directie = `UP;
						end
						else if(directie == `DOWN)begin
							directie = `LEFT;
						end
						//fac un pas in fata
						if(directie == `RIGHT)begin
							col_curent = col_curent + 1;
						end
						else if(directie == `UP)begin
							row_curent = row_curent - 1;
						end
						else if(directie == `LEFT)begin
							col_curent = col_curent - 1;
						end
						else if(directie == `DOWN)begin
							row_curent = row_curent + 1;
						end
						next_state = `directie_posibila;
						maze_we = 1;
						maze_oe = 0;
					end
					//daca peretele din dreapta nu este liber, atunci ma uit in fata
					else if(maze_in == 1)begin 
						if(directie == `RIGHT)begin
							col = col_curent + 1;
						end
						else if(directie == `UP)begin
							row = row_curent - 1;
						end
						else if(directie == `LEFT)begin
							col = col_curent - 1;
						end
						else if(directie == `DOWN)begin
							row = row_curent + 1;
						end
						next_state = `perete_fata;
						maze_we = 0;
						maze_oe = 1;
					 end
				end
				
				`perete_fata: begin 
					row = row_curent;
					col = col_curent;
					if(maze_in == 0)begin // peretele din fata e liber, nu trebuie sa schimb pozitia
					//fac un pas in fata
						if(directie == `RIGHT)begin
							col_curent = col_curent + 1;
						end
						else if(directie == `UP)begin
							row_curent = row_curent - 1;
						end
						else if(directie == `LEFT)begin
							col_curent = col_curent - 1;
						end
						else if(directie == `DOWN)begin
							row_curent = row_curent + 1;
						end
						next_state = `directie_posibila;
						maze_we = 1;
						maze_oe = 0;	
					end
					//daca peretele din fata nu este liber, atunci privesc spre stanga
					else if(maze_in == 1)begin 	
						if(directie == `RIGHT)begin
								row = row_curent - 1;
							end
							else if(directie == `UP)begin
								col = col_curent - 1;
							end
							else if(directie == `LEFT)begin
								row = row_curent + 1;
							end
							else if(directie == `DOWN)begin
								col = col_curent + 1;
							end
						next_state = `perete_stanga;
						maze_we = 0;
						maze_oe = 1;
					end
				end
						
					`perete_stanga:begin
						row = row_curent;
						col = col_curent;
						if(maze_in == 0)begin // peretele din stanga e liber
							//imi modific pozitia spre stanga
							if(directie == `RIGHT)begin
								directie = `UP;
							end
							else if(directie == `UP)begin
								directie = `LEFT;
							end
							else if(directie == `LEFT)begin
								directie = `DOWN;
							end
							else if(directie == `DOWN)begin
								directie = `RIGHT;
							end
							//fac un pas in fata
							if(directie == `RIGHT)begin
								col_curent = col_curent + 1;
							end
							else if(directie == `UP)begin
								row_curent = row_curent - 1;
							end
							else if(directie == `LEFT)begin
								col_curent = col_curent - 1;
							end
							else if(directie == `DOWN)begin
								row_curent = row_curent + 1;
							end
							next_state = `directie_posibila;
							maze_we = 1;
							maze_oe = 0;
						end
						//daca peretele din stanga nu este liber, ma uit in spate
						else if(maze_in == 1)begin 	
							if(directie == `RIGHT)begin
								col = col_curent - 1;
							end
							else if(directie == `UP)begin
								row = row_curent + 1;
							end
							else if(directie == `LEFT)begin
								col = col_curent + 1;
							end
							else if(directie == `DOWN)begin
								row = row_curent - 1;
							end
						next_state = `ultima_incercare;
						maze_we = 0;
						maze_oe = 1;
						 end
					end
					
				`ultima_incercare: begin
					row = row_curent;
					col = col_curent;
					if(maze_in == 0)begin //e liber, ma intorc 180 de grade
						if(directie == `RIGHT)begin
								directie = `LEFT; 
							end
							else if(directie == `UP)begin
								directie = `DOWN;
							end
							else if(directie == `LEFT)begin
								directie = `RIGHT;
							end
							else if(directie == `DOWN)begin
								directie = `UP;
							end
							//fac un pas in fata
							if(directie == `RIGHT)begin
								col_curent = col_curent + 1;
							end
							else if(directie == `UP)begin
								row_curent = row_curent - 1;
							end
							else if(directie == `LEFT)begin
								col_curent = col_curent - 1;
							end
							else if(directie == `DOWN)begin
								row_curent = row_curent + 1;
							end
							next_state = `directie_posibila;
							maze_we = 1;
							maze_oe = 0;
					end
				end
		endcase
	end
endmodule
