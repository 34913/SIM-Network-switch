module Controller
	#(
		// number of output ports
		parameter NUM_OF_PORTS = 5,
		// number of bits required to address the output ports
		PORT_ADDR_LENGTH = 3,
		// number of data bits
		DATA_WIDTH = 8
	)
	(
		input wire clk,
		input wire reset,

		input wire packet_send_req,
		input wire port_found,
		input wire received,

		output reg memory_blocked,
		output reg packet_finished,
		output reg packet_send
	);

	reg [1:0] state;
	reg [1:0] next_state;

	// shifting the state to next one on the rising edge of the clock
	// or reset
	always @ (posedge clk, posedge reset) begin
		if (reset) begin
			state <= 0;
		end
		else begin
			state <= next_state;
		end
	end

	// next state logic based on the current state and input signals
	// automaton for the controller's state transitions, with little changes from the one described on courses
	always @ (*) begin
		next_state = state;

		case (state)
			// IDLE state: waiting for packet send request
			0: begin
				if (packet_send_req == 1'b1) begin
					next_state = 1;
				end
			end
			// DECIDING state: determining if the packet can be sent to the found port
			1: begin
				if (port_found == 1'b1) begin
					next_state = 2;
				end
				else begin
					next_state = 3;
				end
			end
			// SENDING state: sending the packet to the found port
			2: begin
				if (received == 1'b1) begin
					next_state = 3;
				end
			end
			// FINISHED state: acknowledging that it was sent and received or discarded
			3: begin
				next_state = 0;
			end

			default: next_state = 0;
		endcase
	end

	// output signals based on the current state
	always @ (*) begin
		memory_blocked = 0;
		packet_finished = 0;
		packet_send = 0;

		case (state)
			0: begin
			end
			1: begin
			end
			2: begin
				memory_blocked = 1;
				packet_send = 1;
			end
			3: begin
				packet_finished = 1;
			end
		endcase
	end
endmodule