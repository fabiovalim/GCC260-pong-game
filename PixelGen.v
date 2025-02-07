module PixelGen(
    input  wire clk,
    input  wire rstn,
    input  wire video_on, 
    input  wire p_tick,

    // Quatro sinais separados para paddles
    input  wire left_up,      // W
    input  wire left_down,    // S

    input  wire [9:0] pixel_x,
    input  wire [9:0] pixel_y,

    // Saída de cor 12-bit: {4'b red, 4'b green, 4'b blue}
    output reg [3:0] r,
    output reg [3:0] g,
    output reg [3:0] b
);

    //---------------------------------------------------------
    // 1) Parâmetros da tela & objetos
    //---------------------------------------------------------
    localparam SCREEN_W     = 640;
    localparam SCREEN_H     = 480;

    localparam PADDLE_W     = 10;  
    localparam PADDLE_H     = 60;  
    localparam BALL_SIZE    = 5;  

    localparam LEFT_PADDLE_X  = 35;
    // localparam RIGHT_PADDLE_X = SCREEN_W - 30 - PADDLE_W;

    // Cores (12-bit)
    localparam COLOR_BLACK   = 12'h000; // Preto
    localparam COLOR_WHITE   = 12'hFFF; // Branco
    localparam COLOR_RED     = 12'hF00; // Vermelho
    localparam COLOR_GREEN   = 12'h0F0; // Verde
    localparam COLOR_BLUE    = 12'h00F; // Azul
    localparam COLOR_YELLOW  = 12'hFF0; // Amarelo
    localparam COLOR_CYAN    = 12'h0FF; // Ciano
    localparam COLOR_MAGENTA = 12'hF0F; // Magenta
    localparam COLOR_ORANGE  = 12'hFA0; // Laranja
    localparam COLOR_PURPLE  = 12'hA0F; // Roxo
    localparam COLOR_GRAY    = 12'h888; // Cinza
    localparam COLOR_BROWN   = 12'hA52; // Marrom

    //---------------------------------------------------------
    // 2) Tick de atualização do frame: ~60 Hz
    //---------------------------------------------------------
    wire refr_tick;
    assign refr_tick = (pixel_y == 480) && (pixel_x == 0);

    //---------------------------------------------------------
    // 3) Estado do paddle & bola
    //---------------------------------------------------------
    reg [9:0] left_paddle_y;
    reg [9:0] ball_x, ball_y;
    // bits de direção: 1 => move para a direita/baixo, 0 => move para a esquerda/cima
    reg        ball_dir_x, ball_dir_y;

    //---------------------------------------------------------
    // 4) Lógica de inicialização & movimento
    //---------------------------------------------------------
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            // Reset: centra paddles, centra bola
            left_paddle_y  <= (SCREEN_H - PADDLE_H) / 2;
            ball_x         <= (SCREEN_W - BALL_SIZE) / 2;
            ball_y         <= (SCREEN_H - BALL_SIZE) / 2;
            ball_dir_x     <= 1'b1; // começa movendo para a direita
            ball_dir_y     <= 1'b1; // começa movendo para baixo
        end
        else if (refr_tick) begin
            //--------------- Paddle esquerdo ---------------
            // Movimento do paddle esquerdo (W=up, S=down)
            if (left_up && (left_paddle_y >= 4))
                left_paddle_y <= left_paddle_y - 4;
            else if (left_down && ((left_paddle_y + PADDLE_H + 4) <= SCREEN_H))
                left_paddle_y <= left_paddle_y + 4;

            //--------------- Bola ---------------
            // Movimento horizontal
            if (ball_dir_x)
                ball_x <= ball_x + 3;
            else
                ball_x <= ball_x - 3;

            // Movimento vertical
            if (ball_dir_y)
                ball_y <= ball_y + 3;
            else
                ball_y <= ball_y - 3;

            // Verificar colisão com a parte superior/inferior
            if (ball_y <= BALL_SIZE) // Ajuste para colisão no topo
                ball_dir_y <= 1'b1; // bounce down (colidiu com o topo)
            else if (ball_y + BALL_SIZE >= SCREEN_H) // Ajuste para colisão no fundo
                ball_dir_y <= 1'b0; // bounce up (colidiu com o fundo)

            // Verificar colisão com o paddle esquerdo
            if (ball_x <= (LEFT_PADDLE_X + PADDLE_W)) begin
                if ((ball_y + BALL_SIZE >= left_paddle_y) &&
                    (ball_y <= left_paddle_y + PADDLE_H))
                begin
                    // bounce right
                    ball_dir_x <= 1'b1;
                end else begin
                    // perdeu para o paddle esquerdo => reiniciar bola
                    ball_x     <= (SCREEN_W - BALL_SIZE) / 2;
                    ball_y     <= (SCREEN_H - BALL_SIZE) / 2;
                    ball_dir_x <= 1'b1;
                    ball_dir_y <= 1'b1;
                end
            end

            // Verificar colisão com a parede direita
            if ((ball_x + BALL_SIZE) >= SCREEN_W) begin  // Colisão com a parede direita
                // bounce left
                ball_dir_x <= 1'b0;
            end
        end
    end

    //---------------------------------------------------------
    // 5) Detecção de desenho na tela
    //---------------------------------------------------------
    wire left_paddle_on, ball_on;

    assign left_paddle_on =
        (pixel_x >= LEFT_PADDLE_X) &&
        (pixel_x <  LEFT_PADDLE_X + PADDLE_W) &&
        (pixel_y >= left_paddle_y) &&
        (pixel_y <  left_paddle_y + PADDLE_H);

    assign ball_on =
        (pixel_x >= ball_x) &&
        (pixel_x <  (ball_x + BALL_SIZE)) &&
        (pixel_y >= ball_y) &&
        (pixel_y <  (ball_y + BALL_SIZE));

    //---------------------------------------------------------
    // 6) Cor final
    //---------------------------------------------------------
    reg [11:0] rgb_next; // Cor 12-bit = {4'hR,4'hG,4'hB}

    always @* begin
        if (!video_on) begin
            // Fora da área ativa
            rgb_next = COLOR_MAGENTA;
        end else begin
            // Cor de fundo padrão
            rgb_next = COLOR_GREEN;

            // Desenha paddles em branco
            if (left_paddle_on) begin
                rgb_next = COLOR_MAGENTA;
            end

            // Desenha bola em azul
            if (ball_on) begin
                rgb_next = COLOR_WHITE;
            end
        end
    end

    //---------------------------------------------------------
    // 7) Armazenar a cor no p_tick
    //---------------------------------------------------------
    always @(posedge clk) begin
        if (p_tick)
            {r, g, b} <= rgb_next;
    end

endmodule
