.equ LEDS0, 0x2000
.equ LEDS1, 0x2004
.equ LEDS2, 0x2008
.equ TIMER, 0x2020
.equ EDGECAPTURE, 0x2034

_start:
br main ; jump to the main function

interrupt_handler:

addi sp, sp, -12
stw t0, 0(sp)
stw t1, 4(sp)
stw ra, 8(sp)

rdctl t0, ctl4
;test le 3ieme bit
andi t1, t0, 0b100

beq zero, t1 , int_timer
call isr_button

;test le premier bit

int_timer:
andi t1, t0, 1
beq t1,zero, int_fin
call isr_timer

;fin de l'handler

int_fin:


ldw t0, 0(sp)
ldw t1, 4(sp)
ldw ra ,8(sp)
addi sp,sp, 12
addi ea, ea ,-4

eret


isr_button:

addi sp, sp, -12
stw t0, 0(sp)
stw t1, 4(sp)
stw ra, 8(sp)

ldw t0, EDGECAPTURE(zero)
stw r0, EDGECAPTURE(zero)
;prend la valeur des deux premiers button
andi t1 , t0, 1
andi t2, t0, 2
srli t2,t2, 1

ldw t0, LEDS0(zero)
add t0, t0, t2
sub t0, t0, t1
stw t0 , LEDS0(zero)

ldw t0, 0(sp)
ldw t1, 4(sp)
ldw ra, 8(sp)
addi sp,sp, 12
ret

isr_timer:

addi sp, sp, -12
stw t0, 0(sp)
stw t1, 4(sp)
stw ra, 8(sp)

ldw t0 , LEDS1(zero)
addi t0 , t0, 1
stw t0 , LEDS1(zero)

stw zero, TIMER+12(zero)
;
ldw t0, 0(sp)
ldw t1, 4(sp)
ldw ra, 8(sp)
addi sp,sp, 12
ret


main:
stw        zero, LEDS0(zero)            ;initialize counters
stw        zero, LEDS1(zero)
stw        zero, LEDS2(zero)

;initialise le stack pointer dans la ram
addi sp,zero, 0x1500

; enable les deux interrupts dont on se sert
ori t1 , zero,0b101
wrctl ctl3, t1

; enable les interrupt  du pie
addi t1, zero,1
wrctl ctl0, t1

; mettre la period;;;;;;;
addi    t0, zero, 999




stw t0, TIMER+4(zero)
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;mettre le control
ori t0,zero,0b1011
stw t0, TIMER+8(zero)

;counter pour la main loop
add t0, zero,zero

loop:

addi t0,t0,1
stw t0, LEDS2(zero)


br loop