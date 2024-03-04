unit crc16;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

// * CRC table calculated by the following algorithm:
/// *
// * void crc16_ccitt_table_init(void){
// *     unsigned short i, j;
// *     for(i=0; i<256; i++){
// *         unsigned short crc = 0;
// *         unsigned short c = i << 8;
// *         for(j=0; j<8; j++){
// *             if((crc ^ c) & 0x8000) crc = (crc << 1) ^ 0x1021;
// *             else                   crc = crc << 1;
// *             c = c << 1;
// *         }
// *         crc16_ccitt_table[i] = crc;
// *     }
// * }

{
static const unsigned short crc16_ccitt_table[256] =
    0x0000U, 0x1021U, 0x2042U, 0x3063U, 0x4084U, 0x50A5U, 0x60C6U, 0x70E7U,
    0x8108U, 0x9129U, 0xA14AU, 0xB16BU, 0xC18CU, 0xD1ADU, 0xE1CEU, 0xF1EFU,
    0x1231U, 0x0210U, 0x3273U, 0x2252U, 0x52B5U, 0x4294U, 0x72F7U, 0x62D6U,
    0x9339U, 0x8318U, 0xB37BU, 0xA35AU, 0xD3BDU, 0xC39CU, 0xF3FFU, 0xE3DEU,
    0x2462U, 0x3443U, 0x0420U, 0x1401U, 0x64E6U, 0x74C7U, 0x44A4U, 0x5485U,
    0xA56AU, 0xB54BU, 0x8528U, 0x9509U, 0xE5EEU, 0xF5CFU, 0xC5ACU, 0xD58DU,
    0x3653U, 0x2672U, 0x1611U, 0x0630U, 0x76D7U, 0x66F6U, 0x5695U, 0x46B4U,
    0xB75BU, 0xA77AU, 0x9719U, 0x8738U, 0xF7DFU, 0xE7FEU, 0xD79DU, 0xC7BCU,
    0x48C4U, 0x58E5U, 0x6886U, 0x78A7U, 0x0840U, 0x1861U, 0x2802U, 0x3823U,
    0xC9CCU, 0xD9EDU, 0xE98EU, 0xF9AFU, 0x8948U, 0x9969U, 0xA90AU, 0xB92BU,
    0x5AF5U, 0x4AD4U, 0x7AB7U, 0x6A96U, 0x1A71U, 0x0A50U, 0x3A33U, 0x2A12U,
    0xDBFDU, 0xCBDCU, 0xFBBFU, 0xEB9EU, 0x9B79U, 0x8B58U, 0xBB3BU, 0xAB1AU,
    0x6CA6U, 0x7C87U, 0x4CE4U, 0x5CC5U, 0x2C22U, 0x3C03U, 0x0C60U, 0x1C41U,
    0xEDAEU, 0xFD8FU, 0xCDECU, 0xDDCDU, 0xAD2AU, 0xBD0BU, 0x8D68U, 0x9D49U,
    0x7E97U, 0x6EB6U, 0x5ED5U, 0x4EF4U, 0x3E13U, 0x2E32U, 0x1E51U, 0x0E70U,
    0xFF9FU, 0xEFBEU, 0xDFDDU, 0xCFFCU, 0xBF1BU, 0xAF3AU, 0x9F59U, 0x8F78U,
    0x9188U, 0x81A9U, 0xB1CAU, 0xA1EBU, 0xD10CU, 0xC12DU, 0xF14EU, 0xE16FU,
    0x1080U, 0x00A1U, 0x30C2U, 0x20E3U, 0x5004U, 0x4025U, 0x7046U, 0x6067U,
    0x83B9U, 0x9398U, 0xA3FBU, 0xB3DAU, 0xC33DU, 0xD31CU, 0xE37FU, 0xF35EU,
    0x02B1U, 0x1290U, 0x22F3U, 0x32D2U, 0x4235U, 0x5214U, 0x6277U, 0x7256U,
    0xB5EAU, 0xA5CBU, 0x95A8U, 0x8589U, 0xF56EU, 0xE54FU, 0xD52CU, 0xC50DU,
    0x34E2U, 0x24C3U, 0x14A0U, 0x0481U, 0x7466U, 0x6447U, 0x5424U, 0x4405U,
    0xA7DBU, 0xB7FAU, 0x8799U, 0x97B8U, 0xE75FU, 0xF77EU, 0xC71DU, 0xD73CU,
    0x26D3U, 0x36F2U, 0x0691U, 0x16B0U, 0x6657U, 0x7676U, 0x4615U, 0x5634U,
    0xD94CU, 0xC96DU, 0xF90EU, 0xE92FU, 0x99C8U, 0x89E9U, 0xB98AU, 0xA9ABU,
    0x5844U, 0x4865U, 0x7806U, 0x6827U, 0x18C0U, 0x08E1U, 0x3882U, 0x28A3U,
    0xCB7DU, 0xDB5CU, 0xEB3FU, 0xFB1EU, 0x8BF9U, 0x9BD8U, 0xABBBU, 0xBB9AU,
    0x4A75U, 0x5A54U, 0x6A37U, 0x7A16U, 0x0AF1U, 0x1AD0U, 0x2AB3U, 0x3A92U,
    0xFD2EU, 0xED0FU, 0xDD6CU, 0xCD4DU, 0xBDAAU, 0xAD8BU, 0x9DE8U, 0x8DC9U,
    0x7C26U, 0x6C07U, 0x5C64U, 0x4C45U, 0x3CA2U, 0x2C83U, 0x1CE0U, 0x0CC1U,
    0xEF1FU, 0xFF3EU, 0xCF5DU, 0xDF7CU, 0xAF9BU, 0xBFBAU, 0x8FD9U, 0x9FF8U,
    0x6E17U, 0x7E36U, 0x4E55U, 0x5E74U, 0x2E93U, 0x3EB2U, 0x0ED1U, 0x1EF0U
}
CONST crc16_table: ARRAY [0..255] OF word = (
 $0000, $1021 , $2042 , $3063 , $4084 , $50A5 , $60C6 , $70E7 ,
 $8108 , $9129 , $A14A , $B16B , $C18C , $D1AD , $E1CE , $F1EF ,
 $1231 , $0210 , $3273 , $2252 , $52B5 , $4294 , $72F7 , $62D6 ,
 $9339 , $8318 , $B37B , $A35A , $D3BD , $C39C , $F3FF , $E3DE ,
 $2462 , $3443 , $0420 , $1401 , $64E6 , $74C7 , $44A4 , $5485 ,
 $A56A , $B54B , $8528 , $9509 , $E5EE , $F5CF , $C5AC , $D58D ,
 $3653 , $2672 , $1611 , $0630 , $76D7 , $66F6 , $5695 , $46B4 ,
 $B75B , $A77A , $9719 , $8738 , $F7DF , $E7FE , $D79D , $C7BC ,
 $48C4 , $58E5 , $6886 , $78A7 , $0840 , $1861 , $2802 , $3823 ,
 $C9CC , $D9ED , $E98E , $F9AF , $8948 , $9969 , $A90A , $B92B ,
 $5AF5 , $4AD4 , $7AB7 , $6A96 , $1A71 , $0A50 , $3A33 , $2A12 ,
 $DBFD , $CBDC , $FBBF , $EB9E , $9B79 , $8B58 , $BB3B , $AB1A ,
 $6CA6 , $7C87 , $4CE4 , $5CC5 , $2C22 , $3C03 , $0C60 , $1C41 ,
 $EDAE , $FD8F , $CDEC , $DDCD , $AD2A , $BD0B , $8D68 , $9D49 ,
 $7E97 , $6EB6 , $5ED5 , $4EF4 , $3E13 , $2E32 , $1E51 , $0E70 ,
 $FF9F , $EFBE , $DFDD , $CFFC , $BF1B , $AF3A , $9F59 , $8F78 ,
 $9188 , $81A9 , $B1CA , $A1EB , $D10C , $C12D , $F14E , $E16F ,
 $1080 , $00A1 , $30C2 , $20E3 , $5004 , $4025 , $7046 , $6067 ,
 $83B9 , $9398 , $A3FB , $B3DA , $C33D , $D31C , $E37F , $F35E ,
 $02B1 , $1290 , $22F3 , $32D2 , $4235 , $5214 , $6277 , $7256 ,
 $B5EA , $A5CB , $95A8 , $8589 , $F56E , $E54F , $D52C , $C50D ,
 $34E2 , $24C3 , $14A0 , $0481 , $7466 , $6447 , $5424 , $4405 ,
 $A7DB , $B7FA , $8799 , $97B8 , $E75F , $F77E , $C71D , $D73C ,
 $26D3 , $36F2 , $0691 , $16B0 , $6657 , $7676 , $4615 , $5634 ,
 $D94C , $C96D , $F90E , $E92F , $99C8 , $89E9 , $B98A , $A9AB ,
 $5844 , $4865 , $7806 , $6827 , $18C0 , $08E1 , $3882 , $28A3 ,
 $CB7D , $DB5C , $EB3F , $FB1E , $8BF9 , $9BD8 , $ABBB , $BB9A ,
 $4A75 , $5A54 , $6A37 , $7A16 , $0AF1 , $1AD0 , $2AB3 , $3A92 ,
 $FD2E , $ED0F , $DD6C , $CD4D , $BDAA , $AD8B , $9DE8 , $8DC9 ,
 $7C26 , $6C07 , $5C64 , $4C45 , $3CA2 , $2C83 , $1CE0 , $0CC1 ,
 $EF1F , $FF3E , $CF5D , $DF7C , $AF9B , $BFBA , $8FD9 , $9FF8 ,
 $6E17 , $7E36 , $4E55 , $5E74 , $2E93 , $3EB2 , $0ED1 , $1EF0

);
  function crc16_it(block:array of byte; len:word; crc:word):word;
implementation
// nsigned short crc16_ccitt(
//        const  nsigned char     block[],
//         nsigned int            blockLength,
//         nsigned short          crc)
//{
//     nsigned int i;

 //   for(i=0 ; i<blockLength; i++){
 //        nsigned short tmp = (crc >> 8) ^ ( nsigned short) block[i];
 //       crc = (( nsigned short)(crc << 8 )) ^ crc16_ccitt_table[tmp];
 //   }
 //   ret rn crc;
//}
function crc16_it(block:array of byte; len:word; crc:word):word;
var tmp,i:word;
begin
for i:=0 to len-1 do
    begin
    tmp:=(crc shr 8) xor (block[i]);
    crc:=(crc shl 8) xor crc16_table[tmp];
    end;
result:=crc;

end;

end.

