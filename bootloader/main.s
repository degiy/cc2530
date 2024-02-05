    .module main


    .include "config.inc"
    .include "regs.inc"

    ;; debut of code area (interrupts)
    .area HOME (CODE,ABS)
    ;.globl _main_prog
    .org 0x0


    .org VEC_RESET
    ljmp    _main_prog
    .org VEC_RFERR
    ljmp user_prog+VEC_RFERR
r6r7todptr:
        mov     dpl, r6
        mov     dph, r7
        ret
    .org VEC_ADC
    ljmp user_prog+VEC_ADC
dptrtor6r7:
        mov     r6, dpl
        mov     r7, dph
        ret
    .org VEC_URX0
    ljmp _urx0
r4r5todptr:
        mov     dpl, r4
        mov     dph, r5
        ret
    .org VEC_URX1
    ljmp user_prog+VEC_URX1
dptrtor4r5:
        mov     r4, dpl
        mov     r5, dph
        ret
    .org VEC_ENC
    ljmp user_prog+VEC_ENC
r2r3todptr:
        mov     dpl, r2
        mov     dph, r3
        ret
    .org VEC_ST
    ljmp user_prog+VEC_ST
dptrtor2r3:
        mov     r2, dpl
        mov     r3, dph
        ret
    .org VEC_P2INT
    ljmp user_prog+VEC_P2INT
r0r1todptr:
        mov     dpl, r0
        mov     dph, r1
        ret
    .org VEC_UTX0
    ljmp user_prog+VEC_UTX0
dptrtor0r1:
        mov     r0, dpl
        mov     r1, dph
        ret
    .org VEC_DMA
    ljmp user_prog+VEC_DMA
    .org VEC_T1
    ljmp user_prog+VEC_T1
    .org VEC_T2
    ljmp user_prog+VEC_T2
    .org VEC_T3
    ljmp user_prog+VEC_T3
    .org VEC_T4
    ljmp user_prog+VEC_T4
    .org VEC_P0INT
    ljmp user_prog+VEC_P0INT
    .org VEC_UTX1
    ljmp user_prog+VEC_UTX1
    .org VEC_P1INT
    ljmp user_prog+VEC_P1INT
    .org VEC_RF
    ljmp user_prog+VEC_RF
    .org VEC_WDT
    ljmp user_prog+VEC_WDT

_main_prog:
    mov sp, #stack - 1
    mov MEM_MEMCTR,#0b00001000  ; map memory to 0x8000 - 0x9fff area of code memory
    acall   _irq_init
    acall   _clock_init
    acall   _uart_init
    acall   _install_defaut_user_prog
    mov dptr,#_txt_boot
    acall   _print
    ;; for dump area
    clr IEN0_EA
    mov CPU_PSW,#0b00001000     ; switch to bank of registers 1
    mov r6,#0
    mov r7,#0
    mov r4,#0
    mov r5,#0
    mov CPU_PSW,#0b00000000     ; switch to bank of registers 0
    setb IEN0_EA
_ml:
    sjmp _ml
    ret

_clock_init:
    mov PMC_CLKCONCMD, #0x80 ; 128 -128
_wait_for_clock_to_be_stable:
    nop
    mov A, PMC_CLKCONSTA
    mov C, A.6
    ;; check if current system clock is 32MHz or just 16
    jc _wait_for_clock_to_be_stable
    ;; ok we have 32MHz
    mov A, PMC_CLKCONCMD
    anl A, #0xC7    ; 199  -57 'Ç'
    ;; we clear 3 bits      1100 0111 => TICKSPD = 000 : 32MHz (timer clock)
    orl A, #0x28     ;  40 '('
    ;; and force up 0010 1000 => TCIKSPD = 101 : 1MHz
    ;; so tick speed to 1MHz for timers
    mov PMC_CLKCONCMD, A

    ;; mov PMC_CLKCONCMD,#0x80      ; 32MHz cristal clock and 32kHz RC clock
    ;; mov r0,#PMC_CLKCONSTA
;; _wait_for_clock:
    ;; cjne @r0,#0x80,_wait_for_clock
    ret

_irq_init:
    clr IEN0_EA
    clr A
    mov CPU_IEN0,A              ; disable ints
    mov CPU_IEN1,A
    mov CPU_IEN2,A
    setb IEN0_EA          ; all interrupts are managed individually
    ret

_uart_init:
    mov USART_U0BAUD,#216       ; mantissa for 115200
    mov USART_U0GCR,#11         ; exp of bauds for 115200
    ;; mov USART_U0BAUD,#59       ; mantissa for 9600
    ;; mov USART_U0GCR,#8         ; exp of bauds for 9600
    mov IOC_PERCFG,#0b00000010  ; send UART1 to P1 and keep UART0 for P0
    mov IOC_P0SEL,#0b00001100   ; RX and TX managed as peripheral
    mov IOC_P0DIR,#0b00001000   ; RX and TX of UART 0 direction set (U0 : TX=3,RX=2)
    mov USART_U0UCR,#0b00000010       ; 1 bit start (down), 1 bit stop (up), 8 bits, no parity, no hw flow ctrl
    mov USART_U0UCR,#0b10000010         ; reset
    mov USART_U0CSR,#0x80       ; UART no SPI, received disabled
    setb IEN0_URX0IE        ; interrupt on RX
    mov USART_U0CSR,#0xC0       ; received enabled
    mov USART_U0DBUF,#'@'       ; first byte sent
    ret


    ;;  2 phases in upload : size recovery, then data
    ;; we do not write back on uart to keep receiving all rx interrupts
_upload_ongoing:
    mov A,USART_U0DBUF
    acall r2r3todptr
    movx    @dptr,a             ; store the read byte to memory loc
    inc dptr                    ; inc memory loc
    acall   dptrtor2r3
    acall   r4r5todptr
    inc dptr                    ; inc neg count, up to 0
    acall   dptrtor4r5
    ;; acall _pint8
    ;; acall newline
    cjne    r4,#00,_hub_exit
    cjne    r5,#00,_hub_exit
_upload_end:
    ;; acall newline
    cjne    r3,#0x1f,_upload_real_end            ; we finished upload (phase 2) because we didn't copy in 0x1f?? area
    mov dptr,#begin_up_xdata               ; we finished uploading size (phase 1), we did copy in r0/r1 area
    acall   dptrtor2r3              ; set the next copy add (user prog one)
    clr a                           ; calc the 2-complement of r0,r1 -> r4,r5
    clr PSW_CY
    subb a,r0
    mov r4,a
    clr a
    subb a,r1
    mov r5,a
    ;; mov dptr,#_txt_size_received
    ;; acall   _print
    ;; acall r4r5todptr
    ;; acall phex16
    ;; acall newline
_hub_exit:                      ;
    ajmp _urx0_exit
_upload_real_end:
    mov dptr,#_txt_end_upload
    acall   _print
    sjmp    _reset

    ;;  serial reception from uart0, on a byte mode
    ;;  use register bank 1 with interrupts disabled
    ;; r6,r7 : Dump location in memory (incremented at each command D)
    ;; r4,r5 : For remaining bytes to copy (negative value) : a r5 value not null means : we are on an upload phase
    ;; r2,r3 : For upload next byte location (in upload mode)
    ;; r0,r1 : For size of upload (in upload mode phase 1)

_urx0:                          ; interrupt handling for char reception on uart0 (control)
    clr TCON_URX0IF
    push acc
    clr IEN0_EA                 ; disable interrupts, as we plan to use bank of regs 1 and don't want to be annoyed during process
    mov CPU_PSW,#0b00001000     ; switch to bank of registers 1
    mov A, r5
    jnz _upload_ongoing
    mov A, USART_U0DBUF
    cjne    A,#'B',_no_boot      ; reboot
    mov dptr,#_txt_reboot
    acall   _print
    mov dptr,#_main_prog
    sjmp    _change_return
_no_boot:
    cjne    A,#'R',_no_reset      ; reset user prog
_reset:
    mov dptr,#_txt_reset
    acall   _print
    mov dptr,#user_prog
_change_return:                 ; we want the reti to bring us somewhere else
    mov a,CPU_SP
    add a,#-3
    mov CPU_SP,a
    push CPU_DPL0
    push CPU_DPH0
    sjmp    _urx0_exit2
_no_reset:
    cjne    A,#'U',_no_upload      ; upload code to $9000 and jump to it
    ;; mov dptr,#_txt_upload
    ;; acall   _print
    mov dptr,#0xfffe                ; need to read size first (2 bytes) at r0-r1 (lsb/msb)
    acall   dptrtor4r5
    mov dptr,#0x1f08
    acall   dptrtor2r3
    mov dptr,#_ml               ; change return of interrup to main loop (we need to quit user prog while downloading)
    sjmp    _change_return
_no_upload:
    cjne    A,#'J',_no_jump     ; jump somewhere : TODO
    mov dptr,#_txt_jump
    acall   _print
    sjmp    _urx0_exit
_no_jump:
    push CPU_DPL0               ; from here we need to save DPTR, because it matters
    push CPU_DPH0
    cjne    A,#'D',_no_dump     ; dump xmem
    mov dptr,#_txt_dump
    acall   _print
    acall   dump
    sjmp    _urx0_pop_dp
_no_dump:
    cjne    A,#'d',_no_dlow     ; dump 8 bits memory (with SFR)
    mov dptr,#_txt_dlow
    acall   _print
    acall   dlow
    sjmp    _urx0_pop_dp
_no_dlow:
    cjne    A,#'0',_no_zero     ; zero dump address
    mov dptr,#_txt_rdump
    acall   _print
    mov r6,#0
    mov r7,#0
    sjmp   _urx0_pop_dp
_no_zero:
    mov dptr,#_txt_usage
    acall   _print
_urx0_pop_dp:
    pop CPU_DPH0
    pop CPU_DPL0
_urx0_exit:
    pop acc
_urx0_exit2:
    mov CPU_PSW,#0b00000000     ; switch to bank of registers 0
    setb IEN0_EA
    reti

_print:
    push acc
_print_1:
    clr a
    movc a,@a+dptr
    jz  _print_0
    acall   cout
    inc dptr
    sjmp    _print_1
_print_0:
    pop acc
    ret

dspace: acall   space
space:  mov     a, #' '
cout:
    push acc
_cout_w_tx:
    mov A,USART_U0CSR
    anl A,#0b00000010
    jz  _cout_w_tx
    anl USART_U0CSR,#0b11111101
    pop acc
    mov USART_U0DBUF,A
    ret

newline:
    push    acc             ;print one newline
    mov     a, #13
    acall   cout
    mov     a, #10
    acall   cout
    pop     acc
    ret

_pint8:
    push    b
    push    acc
pint8b:
    mov     b, #100
    div     ab
    setb    f0
    jz      pint8c
    clr     f0
    add     a, #'0'
    acall   cout
pint8c:
    mov     a, b
    mov     b, #10
    div     ab
    jnb     f0, pint8d
    jz      pint8e
pint8d:
    add     a, #'0'
    acall   cout
pint8e:
    mov     a, b
    add     a, #'0'
    acall   cout
    pop     acc
    pop     b
    ret

_install_defaut_user_prog:
    mov r0,#(_end_up-_def_up)
    anl CPU_DPS,#0xfe
    mov dptr,#_def_up
    orl CPU_DPS,#1
    mov dptr,#begin_up_xdata
_idup_loop:
    anl CPU_DPS,#0xfe
    clr a
    movc a,@a+dptr
    inc dptr
    orl CPU_DPS,#1
    movx @dptr,a
    inc dptr
    djnz r0,_idup_loop
    anl CPU_DPS,#0xfe
    ret

_def_up:
    mov dptr,#_txt_dup
    lcall   _print
    ljmp    _main_prog
    .ascii  "<<end>>"
_end_up:

phex:
phex8:
        acall   phex_b
phex_b: swap    a               ;SWAP A will be twice => A unchanged
phex1:  push    acc
        anl     a, #15
        add     a, #0x90        ; acc is 0x9X, where X is hex digit
        da      a               ; if A to F, C=1 and lower four bits are 0..5
        addc    a, #0x40
        da      a
        acall   cout
        pop     acc
        ret

phex16:
        push    acc
        mov     a, dph
        acall   phex
        mov     a, dpl
        acall   phex
        pop     acc
        ret

dump:
        mov     r2, #16         ;number of lines to print
        acall   newline
dump1:  acall   r6r7todptr
        acall   phex16          ;tell 'em the memory location
        mov     a,#':'
        acall   cout
        acall   space
        mov     r3, #16         ;r3 counts # of bytes to print
        acall   r6r7todptr
dump2:
        movx    a, @dptr
        inc     dptr
        acall   phex            ;print each byte in hex
        acall   space
        djnz    r3, dump2
        acall   dspace          ;print a couple extra space
        mov     r3, #16
        acall   r6r7todptr
dump3:
        movx    a, @dptr
        inc     dptr
        anl     a, #0x7f   ;avoid unprintable characters
        cjne    a, #127, dump3b
        clr     a               ;avoid 127/255 (delete/rubout) char
dump3b: add     a, #224
        jc      dump4
        clr     a               ;avoid control characters
dump4:  add     a, #32
        acall   cout
        djnz    r3, dump3
        acall   newline
        acall   dptrtor6r7
        djnz    r2, dump1       ;loop back up to print next line
        ajmp    newline

dlow:
        mov     r0,#0
        mov     r2, #16         ;number of lines to print
        acall   newline
dlow1:  mov a,r0
        acall   phex8          ;tell 'em the memory location
        mov     a,#':'
        acall   cout
        acall   space
        mov     r3, #16         ;r3 counts # of bytes to print
        mov     a,r0
        mov     r1,a
dlow2:
        mov     a, @r1
        inc     r1
        acall   phex            ;print each byte in hex
        acall   space
        djnz    r3, dlow2
        acall   dspace          ;print a couple extra space
        mov     r3, #16
dlow3:
        mov     a, @r0
        inc     r0
        anl     a, #0x7f   ;avoid unprintable characters
        cjne    a, #127, dlow3b
        clr     a               ;avoid 127/255 (delete/rubout) char
dlow3b: add     a, #224
        jc      dlow4
        clr     a               ;avoid control characters
dlow4:  add     a, #32
        acall   cout
        djnz    r3, dlow3
        acall   newline
        djnz    r2, dlow1       ;loop back up to print next line
        ajmp    newline


    ;; .area   CSEG (CODE)
    ;; .area   CONST (CODE)
_txt_boot:
    .ascii "boot done!"
    .db 10,13,0
_txt_upload:
    .ascii  "start upload"
    .db 10,13,0
_txt_reset:
    .ascii  "reset user prog"
    .db 10,13,0
_txt_jump:
    .ascii  "jump to where ?"
    .db 10,13,0
_txt_reboot:
    .ascii "calling boot"
    .db 10,13,0
_txt_usage:
    .ascii "usage : B (reboot), R (reset user prog), U (upload user prog), J (jump to), d (dump ram), D (dump xram), 0 (reset dump @)"
    .db 10,13,0
_txt_dup:
    .ascii "! default program ! upload a genuine one, rebooting..."
    .db 10,13,0
_txt_dlow:
    .ascii "Dump RAM :"
    .db 10,13,0
_txt_dump:
    .ascii "Dump XRAM :"
    .db 10,13,0
_txt_rdump:
    .ascii "resuming @ of next dump to 0"
    .db 10,13,0
_txt_end_upload:
    .ascii "end of upload, jumping to user program"
    .db 10,13,0
_txt_size_received:
    .ascii "size received : complement is "
    .db 0
