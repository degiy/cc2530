    .module prog

    .include "../bootloader/config.inc"
    .include "../bootloader/regs.inc"
    .include "../bootloader/main.exp"

    .area   HOME (CODE, ABS)


    .org    user_prog
    ajmp    _main

    .org    user_prog+VEC_RFERR
    reti
    .org    user_prog+VEC_ADC
    reti
    .org    user_prog+VEC_URX1
    reti
    .org    user_prog+VEC_ENC
    reti
    .org    user_prog+VEC_ST
    reti
    .org    user_prog+VEC_P2INT
    reti
    .org    user_prog+VEC_UTX0
    reti
    .org    user_prog+VEC_DMA
    reti
    .org    user_prog+VEC_T1
    reti
    .org    user_prog+VEC_T3
    reti
    .org    user_prog+VEC_T4
    reti
    .org    user_prog+VEC_P0INT
    reti
    .org    user_prog+VEC_UTX1
    reti
    .org    user_prog+VEC_P1INT
    reti
    .org    user_prog+VEC_RF
    reti
    .org    user_prog+VEC_WDT

_main:
    mov     dptr, #_txt_user_start
    lcall   _print

iloop:
    sjmp    iloop

_txt_user_start:
    .ascii  "start of user prog #1"
    .db 10,13,0
