module network_switch_tb
	#(
		// number of output ports
		parameter NUM_OF_PORTS = 5,
		// number of bits required to address the output ports
		PORT_ADDR_LENGTH = 3,
		// number of data bits
		DATA_WIDTH = 8
	)
	(

	);

	reg [DATA_WIDTH - 1 : 0] packet_data;
	reg [PORT_ADDR_LENGTH - 1 : 0] packet_addr;

	reg packet_send_req;
	wire packet_finished;

	reg [$clog2(NUM_OF_PORTS) - 1 : 0] mem_port_index;
	reg [PORT_ADDR_LENGTH - 1 : 0] mem_port_addr;
	reg mem_write_enable;

	reg clk;
	reg reset;

	wire [NUM_OF_PORTS - 1 : 0] port_req;
	wire [NUM_OF_PORTS * DATA_WIDTH - 1 : 0] port_data;
	reg [NUM_OF_PORTS - 1 : 0] port_received;

	// connect the Network Switch module here
	Network_Switch #(
		.NUM_OF_PORTS(NUM_OF_PORTS),
		.PORT_ADDR_LENGTH(PORT_ADDR_LENGTH),
		.DATA_WIDTH(DATA_WIDTH)
	) DUT (
		.clk(clk),
		.reset(reset),
		.packet_data(packet_data),
		.packet_addr(packet_addr),
		.packet_send_req(packet_send_req),
		.packet_finished(packet_finished),
		.mem_port_index(mem_port_index),
		.mem_port_addr(mem_port_addr),
		.mem_write_enable(mem_write_enable),
		.port_req(port_req),
		.port_data(port_data),
		.port_received(port_received)
	);

	// setup initial values
	task init;
	begin
		clk = 0;
		reset = 0;
		mem_port_index = 0;
		mem_port_addr = 0;
		mem_write_enable = 0;
		packet_data = 0;
		packet_addr = 0;
		packet_send_req = 0;
		port_received = 0;
	end
	endtask

	task reset_switch;
	begin
		reset = 1;
		#10 reset = 0;

		#10; // wait for the switch to come out of reset
	end
	endtask

	task TEST1;
	begin

		// set address 1 to port 0
		mem_port_index = 0;
		mem_port_addr = 1;
		mem_write_enable = 1;
		#10 mem_write_enable = 0;

		#10; // wait for the address to be set

		// start sending the packet to address 1
		packet_addr = 1;
		packet_data = 8'hAA;
		packet_send_req = 1;
		#10 packet_send_req = 0;

		wait (port_req[0]);

		// any other ports should not have received the packet
		if (port_req[1] || port_req[2]) begin
			$display("TEST1 failed: packet routed to incorrect port");
			$finish;
		end

		// any other ports should not have the data
		if (port_data[1 * DATA_WIDTH +: DATA_WIDTH] == 8'hAA) begin
			$display("TEST1 failed: data on port 1");
			$finish;
		end
		else if (port_data[2 * DATA_WIDTH +: DATA_WIDTH] == 8'hAA) begin
			$display("TEST1 failed: data on port 2");
			$finish;
		end
		else if (port_data[0 * DATA_WIDTH +: DATA_WIDTH] !== 8'hAA) begin
			$display("TEST1 failed: incorrect data on port 0");
			$finish;
		end

		// prepare for test 3, should not set the memory due to the ongoing transmission
		mem_port_index = 1; // example port index
		mem_port_addr = 2;  // example address to set
		mem_write_enable = 1;
		#10 mem_write_enable = 0;

		port_received[0] = 1;
		#10;

		wait (packet_finished);

		// wait for the packet to be finished before checking the port requests and packet_finished signals again
		#10 port_received[0] = 0;
		#10;

		if (port_req[0]) begin
			$display("TEST1 failed: port_req[0] should be low after packet is finished");
			$finish;
		end
		else if (packet_finished) begin
			$display("TEST1 failed: packet_finished should be low after packet is finished");
			$finish;
		end

		$display("TEST1 passed");
		#10;

	end
	endtask

	task TEST2;
	begin

		// start sending the packet to an address that does not exist in the memory
		packet_addr = 5;
		packet_data = 8'hAA;
		packet_send_req = 1;
		#10 packet_send_req = 0;

		// check that no ports have received the packet
		if (port_req[0] || port_req[1] || port_req[2]) begin
			$display("TEST2 failed: packet should not be routed to any port");
			$finish;
		end

		wait (packet_finished);
		#10;

		$display("TEST2 passed");
		#10;

	end
	endtask

	task TEST3;
	begin

		// start sending the packet to an address that was attempted to be set during ongoing transmission
		packet_addr = 2;
		packet_data = 8'hAA;
		packet_send_req = 1;
		#10 packet_send_req = 0;

		// check that no ports have received the packet since the memory was set during transmission
		if (port_req[0] || port_req[1] || port_req[2]) begin
			$display("TEST3 failed: packet should not be routed to any port, memory was set during packet transmission");
			$finish;
		end

		wait (packet_finished);
		#10;

		$display("TEST3 passed");
		#10;

	end
	endtask

	task TEST4;
	begin
		// attempt to set the same address on two different ports
		// address 1 is already set on port 0, so it should not be allowed to set it on port 1
		mem_port_index = 1;
		mem_port_addr = 1;
		mem_write_enable = 1;
		#10 mem_write_enable = 0;

		// send the packet, should arrive only on port 0
		packet_addr = 1;
		packet_data = 8'hAA; // example data
		packet_send_req = 1;
		#10 packet_send_req = 0;

		wait (port_req[0]);

		// Check if the switch correctly prevents setting the same address on two ports
		if (port_req[0] && port_req[1]) begin
			$display("TEST4 failed: two ports have the same address");
			$finish;
		end

		port_received[0] = 1;
		#10;

		wait (packet_finished);
		#10;

		port_received[1] = 1;
		#10;

		if (!packet_finished) begin
			$display("TEST4 failed: packet should be finished");
			$finish;
		end

		$display("TEST4 passed");
		#10;
	end
	endtask

	initial begin
		$dumpfile("network_switch_tb.vcd");
		$dumpvars(0,network_switch_tb);

		init;
		reset_switch;

		// The Network Switch module tests functionality:

		// 1) odesílá pakety z WAN portu na LAN port, jehož adresa se shoduje s adresou požadovanou odesílatelem,
		// 2) umožňuje nastavit adresy jednotlivých LAN portů a uložit si je do paměti,
		// 4) v případě existující adresy paket pošle na správný port a čeká na potvrzení od cílového zařízení,
		// 7) nereaguje na potvrzení od jiného portu, než na který odesílá data.
		TEST1;
		// 3) v případě neexistující adresy paket zahodí a hlásí připravenost pro příjem dalšího,
		TEST2;
		// 5) neumožní změnu adres portů během odesílání paketu,
		TEST3;
		// 6) neumožní nastavit dvěma portům stejnou adresu (pozor na adresu 0 po resetu - lze ji zakázat/ignorovat jako neplatnou),
		TEST4;

		#100;

		$finish;
	end

	always #5 clk = ~clk;

endmodule