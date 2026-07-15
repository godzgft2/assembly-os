[org 0x7c00] ; Offset for bootsector

mov bp, 0x8000 ; sets the stack away from bootsector
mov sp, bp

mov bx, 0x9000 ; es:bx = 0x0000:0x9000 = 0x09000
mov dh, 2 ; read 2 sectors

call disk_load

mov bx, FIRST
call print

mov dx, [0x9000] ; get first word
call print_hex

call print_nl

mov bx, SECOND
call print

mov dx, [0x9000 + 512] ; get first word from second sector
call print_hex

call print_nl

; Sets up parameters then call function
mov bx, START
call print

call print_nl

mov bx, END
call print


; Infinite loop
jmp $

; ---------- Print Hexadecimal ----------
; Uses dx register
print_hex:
    pusha

    mov cx, 0 ; index variable

; convert last char of dx to ASCII
; add 0x30 to byte to get ASCII number, add 0x40 to hex letter for ASCII
; move ASCII to its position on final string
hex_loop:
    cmp cx, 4 ; loop 4 times
    je end
    
    mov ax, dx
    and ax, 0x000f ; make first three zero
    add al, 0x30 ; convert to ASCII
    cmp al, 0x39 ; add 8 for A-F
    jle step2
    add al, 7

step2:
    ; bx <- base address + string length - index of char
    mov bx, HEX_OUT + 5 ; base + length
    sub bx, cx  ; our index variable
    mov [bx], al ; put ASCII char in position
    ror dx, 4 ; rotate dx 4 times

    ; increment index and loop
    add cx, 1
    jmp hex_loop

end:
    ; move result to bx for printing
    mov bx, HEX_OUT
    call print

    popa
    ret

HEX_OUT:
    db '0x0000',0 ; result string


; ---------- Print String ----------

print:
    pusha  ;  store all registers before function



start:
    mov al, [bx] ; bx address for string
    cmp al, 0 
    je done

    ; Print with BIOS interrupt
    mov ah, 0x0e
    int 0x10

    ; increment pointer and do next loop
    add bx, 1
    jmp start

done:
    popa  ;  return registers to before function call
    ret



print_nl:
    pusha
    
    mov ah, 0x0e
    mov al, 0x0a ; newline char
    int 0x10
    
    mov al, 0x0d ; carriage return
    int 0x10
    
    popa
    ret


; ---------- Disk Loader ----------
; loads 'dh' sectors from drive 'dl' into ES:BX
disk_load:
    pusha

    push dx ; save dx for later

    mov ah, 0x02 ; read number
    mov al, dh   ; number of sectors to read, set to 2
    mov cl, 0x02 ; first available sector
    mov ch, 0x00 ; cylinder
    ; dl is drive number
    mov dh, 0x00 ; head number

    int 0x13      ; BIOS interrupt
    jc disk_error ; if error (stored in the carry bit)

    pop dx
    cmp al, dh    ; al and dh should be the same
    jne sectors_error
    popa
    ret


disk_error:
    mov bx, DISK_ERROR
    call print
    call print_nl
    mov dh, ah ; ah has the error code and dl is the drive that had the error
    call print_hex
    jmp disk_loop

sectors_error:
    mov bx, SECTORS_ERROR
    call print

disk_loop:
    jmp $

DISK_ERROR: db "Disk read error", 0
SECTORS_ERROR: db "Incorrect number of sectors read", 0

; ---------- Ending of Main Segment ----------

; data
START:
    db 'Hello, Welcome to my basic OS!', 0

END:
    db 'Thanks for using this OS!', 0
    
FIRST:
    db 'First word stored in first sector: ', 0

SECOND:
    db 'First word stored in second sector: ', 0

; padding and magic number
times 510-($-$$) db 0
dw 0xaa55
