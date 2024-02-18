    ;; a sample program to user timer 1 in modulo mode to produce a "." on uart each second
    .module prog

    .include "../bootloader/config.inc"
    .include "../bootloader/regs.inc"
    .include "../bootloader/main.exp"

    cpt1    =0x20               ; value of counter decremented at 100Hz
    cpt1init=0x21               ; value to reset to count 100 times 1/100s

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
    ajmp    _vec_t1
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
    acall   _timer_init

l_iloop:
    sjmp    l_iloop

_timer_init:
    clr     IEN0_EA
    mov     TIM_T1CC0L,#(10000&0xFF)
    mov     TIM_T1CC0H,#(10000>>8) ; ov every 10ms (100Hz)
    mov     TIM_T1CCTL0,#0b01000100 ; to enable channel 0 (modulo int)
    mov     TIM_T1CTL,#0b000010     ; modulo on tick freq (1MHz)
    clr     TIMIF_OVFIM             ; disable overflown int on t1 as modulo use channel 0
    clr     a
    mov     TIM_T1CNTL,a  ; reset timer
    setb    IEN1_T1IE               ; enable ints for timer 1
    mov     a,#100           ; to have an int every sec
    mov     cpt1init,a
    mov     cpt1,a
    setb    IEN0_EA
    ret

_vec_t1:
    push    acc
    clr     IRCON_T1IF
    anl    TIM_T1STAT,#0b11111110 ;clr ch0 int
    mov     a,cpt1
    dec     a
    jnz     1$
    mov     a,#'.'
    lcall   _cout
    mov     a,cpt1init          ; reset counter
1$:
    mov     cpt1,a
    pop     acc
    reti

_txt_user_start:
    .ascii  "start of user prog --timer--"
    .db 10,13,0
