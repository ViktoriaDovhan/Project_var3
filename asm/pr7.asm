.model small
.stack 100h

.data
mes db "Success $"
mesBad db "File error $"
buffInd db 0; Index to keep track of the current position in buffer
oneChar db 0

keys db 5000*16 dup(0)
keyInd dw 0
isWord db 1
values db 5000*16 dup(0)
valInd dw 0

.code
main proc
    mov ax, @data
    mov ds, ax

    mov ah, 0Ah ; Read from standard input (keyboard)
    mov dx, offset oneChar ; Buffer to store the input
    int 21h

    mov si, offset oneChar ; Set SI to the beginning of the input buffer
    mov cx, 16 ; Set the counter to the size of the input buffer
    xor bx, bx ; Clear BX

readLoop:
    mov al, [si] ; Move a character from the buffer into AL
    cmp al, 0Dh ; Check if the character is a carriage return
    je endRead ; If it is, end the read process
    mov [keys + bx], al ; Move the character into the keys array
    inc bx ; Increment the index for the keys array
    inc si ; Move to the next character in the buffer
    loop readLoop ; Repeat until all characters are read or buffer is exhausted

endRead:
    mov keyInd, bx ; Store the count of characters read into keyInd

    ; Process the characters in keys array
    mov cx, bx ; Set CX to the number of characters read
    mov si, offset keys ; Set SI to the beginning of the keys array
processLoop:
    mov al, [si] ; Load a character from the keys array
    ; Implement your character processing logic here
    inc si ; Move to the next character in the keys array
    loop processLoop ; Repeat until all characters are processed

    ; Output sorted values array
    mov  si, offset values      ; Set SI to the beginning of the values array
    mov  cx, valInd            ; Number of elements in the array

outputLoop:
    mov  dl, [si]               ; Load value
    mov  ah, 02h                ; DOS function for displaying character
    int  21h                    ; Display character

    inc  si                     ; Move to the next value
    loop outputLoop             ; Repeat until all values are printed

    mov ah, 09h
    mov dx, offset mes
    int 21h

    mov ax, 4C00h
    int 21h

main endp

end main
