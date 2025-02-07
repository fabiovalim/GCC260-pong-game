//Este módulo é essencial para qualquer aplicação de vídeo ou display VGA, pois ele gera os sinais de sincronização
//necessários para controle de um monitor e a renderização dos pixels na tela.
//O controle dos contadores horizontais e verticais é a base para exibir a imagem correta no monitor.


module VGASync(
	input wire clk, rstn,
	output wire hsync, vsync, video_on, p_tick,
	output wire [9:0] pixel_x, pixel_y
);


	// Esses parâmetros definem os valores específicos de tempo para 
	// os sinais de sincronização VGA em uma tela 640x480.
	localparam HD = 640; // 640 pixels (área visível horizontal).
	localparam HF = 48; //  48 pixels (borda à esquerda).
	localparam HB = 16; //  16 pixels (borda à direita)
	localparam HR = 96; // 96 pixels (tempo de retrace horizontal).
	localparam VD = 480; // 480 pixels (área visível vertical).
	localparam VF = 10; // 10 pixels (borda superior).
	localparam VB = 33; // 33 pixels (borda inferior).
	localparam VR = 2; //  2 pixels (tempo de retrace vertical).


	reg mod2_reg;
	wire mod2_next;
	
	//O objetivo é gerar o pulso de pixel, que será usado para controlar a exibição de cada pixel na tela
	reg [9:0] h_count_reg, h_count_next;
	reg [9:0] v_count_reg, v_count_next;

	reg v_sync_reg, h_sync_reg;
	wire v_sync_next, h_sync_next;

	wire h_end, v_end, pixel_tick;
	
	always@(posedge clk, negedge rstn)
		if(rstn == 0)
		begin
			mod2_reg <= 1'b0;
			v_count_reg <= 0;
			h_count_reg <= 0;
			v_sync_reg <= 1'b0;
			h_sync_reg <= 1'b0;
		end
		else
		begin
			mod2_reg <= mod2_next;
			v_count_reg <= v_count_next;
			h_count_reg <= h_count_next;
			v_sync_reg <= v_sync_next;
			h_sync_reg <= h_sync_next;
		end
		
	assign mod2_next = ~mod2_reg;
	assign pixel_tick = mod2_reg;
	

	assign h_end = (h_count_reg == (HD+HF+HB+HR-1));
	
	assign v_end = (v_count_reg == (VD+VF+VB+VR-1));
	
	
	always@*
		if(pixel_tick) // 25 MHz pulse
			if(h_end)
				h_count_next = 0;
			else
				h_count_next = h_count_reg + 1;
		else
			h_count_next = h_count_reg;
			
	always@*
		if(pixel_tick & h_end)
			if(v_end)
				v_count_next = 0;
			else
				v_count_next = v_count_reg + 1;
		else
			v_count_next = v_count_reg;
			
	assign h_sync_next = (h_count_reg >= (HD+HB) &&
								 h_count_reg <= (HD+HB+HR-1));
	
	assign v_sync_next = (v_count_reg >= (VD+VB) &&
								 v_count_reg <= (VD+VB+VR-1));

	assign video_on = (h_count_reg<HD) && (v_count_reg<VD);
	
	assign hsync = h_sync_reg;
	assign vsync = v_sync_reg;
	assign pixel_x = h_count_reg;
	assign pixel_y = v_count_reg;
	assign p_tick = pixel_tick;
	
endmodule