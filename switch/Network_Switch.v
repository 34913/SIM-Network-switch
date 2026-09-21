module Network_Switch
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
		// index portu do paměti adres
		input wire [$clog2(NUM_OF_PORTS) - 1 : 0] mem_port_index,
	
		// adresa portu (lze sloučit s packet_addr)
		input wire [PORT_ADDR_LENGTH - 1 : 0] mem_port_addr,
		// zápis do paměti adres portů
		input wire mem_write_enable,
		// data paketu
		input wire [DATA_WIDTH - 1 : 0] packet_data,
		// cílová adresa paketu
		input wire [PORT_ADDR_LENGTH - 1 : 0] packet_addr,
		// požadavek na odeslání paketu
		input wire packet_send_req,
		// paket byl zahozen/odeslán
		output wire packet_finished,
	
		// (pro každý port) požadavek na odeslání paketu
		output reg [NUM_OF_PORTS - 1 : 0] port_req,
		// (pro každý port) data paketu
		output reg [NUM_OF_PORTS * DATA_WIDTH - 1 : 0] port_data,
		// (pro každý port) paket byl přijat cílovým zařízením
		output reg [NUM_OF_PORTS - 1 : 0] port_received
	);

	// dráty
	wire [PORT_ADDR_LENGTH - 1 : 0] mem_data [NUM_OF_PORTS - 1 : 0];
	wire eq[NUM_OF_PORTS - 1 : 0];

	wire match;
	wire packet_send;
	wire received;

	// bloky
	Memory #(
		.NUM_OF_PORTS(NUM_OF_PORTS),
		.PORT_ADDR_LENGTH(PORT_ADDR_LENGTH)
	) memory (
		.clk(clk),
		.reset(reset),
		.port_index(mem_port_index),
		.port_addr(mem_port_addr),
		.write_enable(mem_write_enable),
		.memory_blocked(),
		.data_addrs(mem_data)
	);

	Comparators #(
		.PORT_ADDR_LENGTH(PORT_ADDR_LENGTH)
	) compare [NUM_OF_PORTS - 1 : 0] (
		.packet_addr(packet_addr),
		.mem_data_all(mem_data),
		.eq(eq)
	);

	Or #(
		.NUM_OF_PORTS(NUM_OF_PORTS)
	) or_block (
		.eq(eq),
		.match(match)
	);

	Controller #(
		.NUM_OF_PORTS(NUM_OF_PORTS),
		.PORT_ADDR_LENGTH(PORT_ADDR_LENGTH),
		.DATA_WIDTH(DATA_WIDTH)
	) controller (
		.clk(clk),
		.reset(reset),
		.packet_send_req(packet_send_req),
		.port_found(match),
		.received(received),
		.packet_finished(packet_finished),
		.packet_send(packet_send)
	);

	Mux_Demux_Logic #(
		.NUM_OF_PORTS(NUM_OF_PORTS),
		.PORT_ADDR_LENGTH(PORT_ADDR_LENGTH),
		.DATA_WIDTH(DATA_WIDTH)
	) mux_demux_logic (
		.packet_data(packet_data),
		.packet_send(packet_send),
		.eq(eq),
		.port_received(port_received),
		.received(received),
		.port_request(port_req),
		.port_data(port_data)
	);

endmodule