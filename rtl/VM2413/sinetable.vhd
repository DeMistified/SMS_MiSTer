--
-- SineTable.vhd
--
-- Copyright (c) 2006 Mitsutaka Okazaki (brezza@pokipoki.org)
-- All rights reserved.
--
-- Redistribution and use of this source code or any derivative works, are
-- permitted provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice,
--    this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright
--    notice, this list of conditions and the following disclaimer in the
--    documentation and/or other materials provided with the distribution.
-- 3. Redistributions may not be sold, nor may they be used in a commercial
--    product or activity without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
-- "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
-- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
-- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
-- EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
-- OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
-- WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
-- OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
--

--
--  modified by t.hara
--

-- ----------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_signed.all;

entity interpolate_mul is
    port (
        i0      : in    std_logic_vector(  8 downto 0 );    --  �������� 9bit (������ 0bit, ������ 9bit)
        i1      : in    std_logic_vector( 11 downto 0 );    --  �����t��12bit (������ 8bit, ������ 4bit)
        o       : out   std_logic_vector( 13 downto 0 )     --  �����t�� 7bit (������ 8bit, ������ 6bit)
    );
end interpolate_mul;

architecture rtl of interpolate_mul is
    signal w_mul    : std_logic_vector( 21 downto 0 );      --  �����t��22bit (������ 9bit, ������13bit)
begin

    w_mul   <= ('0' & i0) * i1;
    o       <= w_mul( 20 downto 7 );        --  MSB�J�b�g�� 21bit, ���������� 7bit�J�b�g
end rtl;

-- ----------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;
    use ieee.std_logic_arith.all;                           --  conv_integer()

entity SineTable is
    port (
        clk     : in    std_logic;
        clkena  : in    std_logic;
        wf      : in    std_logic;
        addr    : in    std_logic_vector( 17 downto 0 );    --  ������ 9bit, ������ 9bit
        data    : out   std_logic_vector( 13 downto 0 )     --  ������ 8bit, ������ 6bit
    );
end SineTable;

architecture rtl of sinetable is
	attribute ramstyle : string;

    component interpolate_mul
        port (
            i0      : in    std_logic_vector(  8 downto 0 );    --  �������� 9bit (������ 0bit, ������ 9bit)
            i1      : in    std_logic_vector( 11 downto 0 );    --  �����t�� 8bit (������ 8bit)
            o       : out   std_logic_vector( 13 downto 0 )     --  �������� 7bit (������ 8bit)
        );
    end component;

    type sin_type is array (0 to 127) of std_logic_vector( 10 downto 0 );  --   ������ 7bit, ������ 4bit
    signal sin_data : sin_type := (
        "11111111111", "11001010000", "10101010001", "10010111100",
        "10001010011", "10000000001", "01110111110", "01110000101",
        "01101010101", "01100101001", "01100000011", "01011100000",
        "01011000000", "01010100011", "01010001000", "01001101111",
        "01001011000", "01001000010", "01000101101", "01000011010",
        "01000000111", "00111110110", "00111100101", "00111010101",
        "00111000110", "00110110111", "00110101001", "00110011100",
        "00110001111", "00110000011", "00101110111", "00101101011",
        "00101100000", "00101010110", "00101001011", "00101000001",
        "00100111000", "00100101110", "00100100101", "00100011100",
        "00100010100", "00100001011", "00100000011", "00011111011",
        "00011110100", "00011101100", "00011100101", "00011011110",
        "00011010111", "00011010001", "00011001010", "00011000100",
        "00010111110", "00010111000", "00010110010", "00010101100",
        "00010100111", "00010100001", "00010011100", "00010010111",
        "00010010010", "00010001101", "00010001000", "00010000011",
        "00001111111", "00001111010", "00001110110", "00001110010",
        "00001101110", "00001101010", "00001100110", "00001100010",
        "00001011110", "00001011010", "00001010111", "00001010011",
        "00001010000", "00001001101", "00001001001", "00001000110",
        "00001000011", "00001000000", "00000111101", "00000111011",
        "00000111000", "00000110101", "00000110011", "00000110000",
        "00000101110", "00000101011", "00000101001", "00000100111",
        "00000100101", "00000100010", "00000100000", "00000011110",
        "00000011101", "00000011011", "00000011001", "00000010111",
        "00000010110", "00000010100", "00000010011", "00000010001",
        "00000010000", "00000001110", "00000001101", "00000001100",
        "00000001011", "00000001010", "00000001001", "00000001000",
        "00000000111", "00000000110", "00000000101", "00000000100",
        "00000000011", "00000000011", "00000000010", "00000000010",
        "00000000001", "00000000001", "00000000000", "00000000000",
        "00000000000", "00000000000", "00000000000", "00000000000"
    );
	 attribute ramstyle of sin_data : signal is "logic";

    signal ff_data0     : std_logic_vector( 10 downto 0 );  --  �����i�V������ 7bit, ������ 4bit
    signal ff_data1     : std_logic_vector( 10 downto 0 );  --  �����i�V������ 7bit, ������ 4bit
    signal w_wf         : std_logic_vector( 13 downto 0 );
    signal w_xor        : std_logic_vector(  6 downto 0 );
    signal w_addr0      : std_logic_vector(  6 downto 0 );
    signal w_addr1      : std_logic_vector(  6 downto 0 );
    signal w_xaddr      : std_logic_vector(  6 downto 0 );
    signal ff_sign      : std_logic;
    signal ff_wf        : std_logic;
    signal ff_weight    : std_logic_vector(  8 downto 0 );
    signal w_sub        : std_logic_vector( 11 downto 0 );  --  �����t�������� 8bit, ������ 4bit
    signal w_mul        : std_logic_vector( 13 downto 0 );  --  �����t�������� 8bit, ������ 6bit
    signal w_inter      : std_logic_vector( 13 downto 0 );
    signal ff_data      : std_logic_vector( 13 downto 0 );
begin

    w_xor   <= (others => addr(16));
    w_xaddr <= addr( 15 downto 9 ) xor w_xor;
    w_addr0 <= w_xaddr;
    w_addr1 <= "1111111" xor w_xor when(addr( 15 downto 9 ) = "1111111" )else   --  �g�`���z���镔���̑Ώ�
               (addr( 15 downto 9 ) + 1) xor w_xor;

    --  �g�`������
    process( clk )
    begin
        if( clk'event and clk = '1' )then
            if( clkena = '1' )then
                ff_data0 <= sin_data( conv_integer( w_addr0 ) );
                ff_data1 <= sin_data( conv_integer( w_addr1 ) );
            end if;
        end if;
    end process;

    --  �C�������̒x���i�g�`�������̓ǂݏo���x���ɂ��킹���j
    process( clk )
    begin
        if( clk'event and clk = '1' )then
            if( clkena = '1' )then
                ff_sign     <= addr(17);
                ff_wf       <= wf and addr(17);
                ff_weight   <= addr( 8 downto 0 );
            end if;
        end if;
    end process;

    --  ����    (���������܂������ꏊ�ł� 0 �ɂȂ邩�� ff_sign �͋C�ɂ��Ȃ��j
    --  o = i0 * (1 - k) + i1 * w = i0 - w * i0 + w * i1 = i0 + w * (i1 - i0)
    w_sub   <= ('0' & ff_data1) - ('0' & ff_data0);

    u_interpolate_mul: interpolate_mul
    port map (
        i0      => ff_weight,
        i1      => w_sub,
        o       => w_mul
    );

    --  ���� 6bit �i�������j��Z���x�ێ��̂��߂Ɏc��
    w_inter <= (ff_data0 & "00") + w_mul;   --  "00" �͌����킹
    w_wf    <= (others => ff_wf);

    process( clk )
    begin
        if( clk'event and clk = '1' )then
            if( clkena = '1' )then
                --  ���ԉ��Z�̌��ʂ����� FF �ɓ����ĉ��Z�x�����z��
                ff_data <= (ff_sign & w_inter(12 downto 0)) or w_wf;
            end if;
        end if;
    end process;

    data <= ff_data;

    --------------------------------------------------------------------------
    --  addr        X addr����  X
    --  w_addr0     X �m��      X
    --  w_addr1     X �m��      X
    --  ff_data0                X �m��      X
    --  ff_data1                X �m��      X
    --  ff_sign                 X �m��      X
    --  ff_wf                   X �m��      X
    --  ff_weight               X �m��      X
    --  w_sub                   X �m��      X
    --  w_mul                   X �m��      X
    --  w_inter                 X �m��      X
    --  w_wf                    X �m��      X
    --  ff_data                             X �m��      X
    --  data                                X �m��      X
    --  Operator
    --    stage     X 01        X 10        X 11        X 00        X
    --
    --  Operator �́Astage = 01 �̂Ƃ��ɓ����������͒l�Ɋ��Â��o�͂𓾂��ꍇ��
    --  stage = 11 �Ŏ󂯎����Ȃ����΂Ȃ��Ȃ��B
    --
    --  �A�h���X�w�肳���Ă����A�����ɑΉ������l�����������܂� 2cycle �̒x��
    --
end rtl;
