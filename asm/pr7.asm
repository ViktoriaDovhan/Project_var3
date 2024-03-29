.model small               ; Об'явлення моделі пам'яті
.stack 100h                ; Розмір стеку

.data
    char            db 0                  ; Одиночний символ
    presIndex       dw 0
    newIndex        dw 0
    keysofarray     db 10000*16 dup(0)   ; Масив ключів
    keyTemp         db 16 dup(0)
    keyTempIndex    dw 0                 ; Індекс тимчасового ключа
    isWord          db 1                 ; Флаг, який вказує, чи є поточний рядок словом
    valuesarray     dw 10000 dup(0)      ; Масив для зберігання чисел
    number          db 16 dup(0)         ; Масив для тимчасового зберігання чисел
    numberIndex     dw 0                 ; Індекс тимчасового числа
    quantityarray   dw 3000 dup(0)       ; Масив для кількості ключів

.code
main proc
    mov ax, @data           ; Завантаження адреси секції даних у регістр ax
    mov ds, ax              ; Переміщення значення регістра ax в регістр ds

read_next:                 ; Мітка для циклу зчитування
    mov ah, 3Fh             ; Служба DOS для відкриття файлу
    mov bx, 0               ; Дескриптор файлу
    mov cx, 1               ; Один байт для зчитування
    lea dx, char            ; Адреса для збереження зчитаного символу
    int 21h                 ; Виклик DOS
    push ax                 ; Збереження значення регістра ax
    call procChar           ; Виклик процедури обробки символів
    pop ax                  ; Відновлення значення регістра ax
    or ax, ax               ; Перевірка, чи зчитаний символ не є кінцем файлу
    jnz read_next           ; Якщо символ не нульовий, зчитати наступний

    lea si, number          ; Завантаження адреси тимчасового числа у регістр si
    dec numberIndex         ; Зменшення індексу тимчасового числа
    add si, numberIndex     ; Додавання індексу до адреси
    mov [si], 0             ; Очищення значення тимчасового числа
    call trnInNum           ; Виклик процедури перетворення в число
    call calcAvr            ; Виклик процедури обчислення середнього значення
    call sortArr            ; Виклик процедури сортування
    call writeArrays        ; Виклик процедури запису масивів

ending:                     ; Мітка для завершення програми
    mov ax, 4C00h           ; Код для виходу з програми
    int 21h                 ; Виклик DOS
main endp
; Процедура обробки символів
procChar proc
    cmp char, 0Dh           ; Перевірка, чи є символ символом нового рядка
    jnz notCR               ; Якщо не так, перевірка на наступний символ
    cmp isWord, 0           ; Перевірка, чи поточний рядок не є словом
    jne endProc             ; Якщо так, завершення процедури
    mov isWord, 1           ; Якщо ні, встановлення флагу isWord в 1
    call trnInNum           ; Виклик процедури перетворення в число
    jmp endProc             ; Завершення процедури
notCR:
    cmp char, 0Ah           ; Перевірка, чи є символ символом нового рядка
    jnz notLF               ; Якщо не так, перевірка на наступний символ
    cmp isWord, 0           ; Перевірка, чи поточний рядок не є словом
    jnz endProc             ; Якщо так, завершення процедури
    mov isWord, 1           ; Якщо ні, встановлення флагу isWord в 1
    call trnInNum           ; Виклик процедури перетворення в число
    jmp endProc             ; Завершення процедури
notLF:
    cmp char, 20h           ; Перевірка, чи є символ пробілом
    jnz notSpace            ; Якщо не так, перевірка на наступний символ
    mov isWord, 0           ; Якщо так, скидання флагу isWord
    call checkKey           ; Виклик процедури перевірки ключа
    jmp endProc             ; Завершення процедури
notSpace:
    cmp isWord, 0           ; Перевірка, чи поточний рядок є словом
    jnz itsWord             ; Якщо так, обробка як слово
    mov si, offset number   ; Завантаження адреси числа у регістр si
    mov bx, numberIndex     ; Завантаження індексу числа у регістр bx
    add si, bx              ; Додавання індексу до адреси
    mov al, char            ; Завантаження символу у регістр al
    mov [si], al            ; Збереження символу в масиві чисел
    inc numberIndex         ; Інкремент індексу числа
    jmp endProc             ; Завершення процедури
itsWord:
    mov si, offset keyTemp  ; Завантаження адреси тимчасового ключа у регістр si
    mov bx, keyTempIndex    ; Завантаження індексу тимчасового ключа у регістр bx
    add si, bx              ; Додавання індексу до адреси
    mov al, char            ; Завантаження символу у регістр al
    mov [si], al            ; Збереження символу у тимчасовому ключі
    inc keyTempIndex        ; Інкремент індексу тимчасового ключа

endProc:
    ret                     ; Повернення з процедури
procChar endp

; Процедура перетворення в число
trnInNum PROC
    xor bx, bx              ; Очищення регістру bx
    mov cx, 0               ; Очищення регістру cx
    calcNum:
        lea si, number          ; Завантаження адреси числа у регістр si
        add si, numberIndex     ; Додавання індексу до адреси
        dec si                  ; Декремент адреси
        sub si, cx              ; Відняття значення cx від адреси
        xor ax, ax              ; Очищення регістру ax
        mov al, [si]            ; Завантаження символу у регістр al
        cmp ax, 45              ; Перевірка, чи є символ мінусом
        jnz notMinus            ; Якщо не так, перейти до наступного кроку
        ret
    notMinus:
        sub al, '0'             ; Відняття коду символу "0" від коду символу у регістрі al
        push cx                 ; Збереження значення регістру cx
        cmp cx, 0               ; Перевірка, чи регістр cx містить 0
        jnz notZer              ; Якщо не так, перейти до наступного кроку
        jmp endOFMul            ; Якщо так, завершити множення на 10
    notZer:
        mulByTen:
        mov dx, 10              ; Завантаження 10 у регістр dx
        mul dx                  ; Множення на 10
        dec cx                  ; Декрементування cx
        cmp cx, 0               ; Перевірка, чи cx не дорівнює 0
        jnz mulByTen            ; Якщо так, повторити множення на 10
    endOFMul:
        pop cx                  ; Відновлення значення регістру cx
        add bx, ax              ; Додавання ax до bx
        inc cx                  ; Інкрементування cx
        cmp cx, numberIndex     ; Порівняння cx з numberIndex
        jnz calcNum             ; Якщо не рівні, повторити обчислення числа
    afterCalc:
        mov si, offset valuesarray  ; Завантаження адреси масиву значень у регістр si
        mov ax, presIndex          ; Завантаження presIndex у регістр ax
        shl ax, 1                   ; Зміщення значення ax вліво на 1 біт (еквівалент множення на 2)
        add si, ax                  ; Додавання значення ax до si
        add bx, [si]                ; Додавання bx до значення, на яке вказує si
        mov [si], bx                ; Збереження нового значення у масиві значень
        mov numberIndex, 0          ; Очищення індексу тимчасового числа
        mov cx, 0                   ; Очищення регістру cx

        fillZeros:
        lea si, number              ; Завантаження адреси числа у регістр si
        add si, cx                  ; Додавання значення cx до si
        mov [si], 0                 ; Заповнення масиву числа нулями
        inc cx                      ; Інкрементування cx
        cmp cx, 9                   ; Порівняння cx з 9
        jnz fillZeros               ; Якщо не рівні, повторити заповнення нулями

        ret
    trnInNum endp

    ; Процедура для перетворення в символ
    turnInChar proc
        pop dx                      ; Вилучення значення dx зі стеку
        pop bx                      ; Вилучення значення bx зі стеку
        shl bx, 1                   ; Зміщення значення bx вліво на 1 біт (еквівалент множення на 2)
        mov ax, [valuesarray + bx]  ; Завантаження слова з адреси, обчисленої за допомогою bx, у регістр ax
        cmp ax, 10000               ; Порівняння ax з 10000
        jc positive                 ; Якщо ax менше за 10000, перейти до мітки positive
        neg ax                      ; Виконати додатковий код для від'ємного числа

        positive:
        shr bx, 1                   ; Зміщення значення bx вправо на 1 біт (еквівалент ділення на 2)
        push bx                     ; Збереження значення bx у стеку
        push dx                     ; Збереження значення dx у стеку
        mov cx, 15                  ; Завантаження значення 15 у регістр cx



        makeChar:
            mov dx, 0                   ; Очищення регістру dx
            mov bx, 10                  ; Завантаження значення 10 у регістр bx
            div bx                      ; Ділення ax на bx
            lea si, keyTemp             ; Завантаження адреси масиву keyTemp у регістр si
            add si, cx                  ; Додавання значення cx до si
            add dx, '0'                 ; Додавання ASCII-коду "0" до значення dx
            mov [si], dl                ; Збереження значення dl у масиві keyTemp
            cmp ax, 0                   ; Порівняння ax з 0
            jnz contSetNumb             ; Якщо ax не дорівнює 0, перейти до мітки contSetNumb
            mov bx, 16                  ; Завантаження значення 16 у регістр bx
            mov numberIndex, bx         ; Збереження значення bx у numberIndex
            sub numberIndex, cx         ; Віднімання значення cx від numberIndex
            jmp reverse_number          ; Перехід до мітки reverse_number

        contSetNumb:
            dec cx                      ; Декрементування cx
            cmp cx, -1                  ; Порівняння cx з -1
            jne makeChar                ; Якщо cx не дорівнює -1, повторити формування символів

        reverse_number:
            mov cx, 16                  ; Завантаження значення 16 у регістр cx
            sub cx, numberIndex         ; Віднімання numberIndex від cx
            mov dx, 0                   ; Очищення регістру dx

        reverse:
            lea si, keyTemp             ; Завантаження адреси масиву keyTemp у регістр si
            add si, cx                  ; Додавання значення cx до si
            lea di, number              ; Завантаження адреси масиву number у регістр di
            add di, dx                  ; Додавання значення dx до di
            mov al, [si]                ; Завантаження байту даних з адреси, на яку вказує si, у регістр al
            mov [di], al                ; Збереження байту даних у масиві number
            inc dx                      ; Інкрементування dx
            inc cx                      ; Інкрементування cx
            cmp cx, 16                  ; Порівняння cx з 16
            jnz reverse                 ; Якщо cx не дорівнює 16, повторити зворотне формування

            ret
        turnInChar endp



        checkKey proc
            mov ax, 0                   ; Очищення регістру ax
            mov bx, 0                   ; Очищення регістру bx
            mov cx, 0                   ; Очищення регістру cx
            mov dx, 0                   ; Очищення регістру dx

            cmp newIndex, 0             ; Перевірка, чи newIndex дорівнює 0
            jnz findKey                 ; Якщо не дорівнює, перейти до пошуку ключа

            call addNewKeyproc   ; Виклик процедури для додавання нового ключа
            findKey:
            mov dx, 0                   ; Очищення регістру dx

            checkPresKey:
            lea si, keysofarray        ; Завантаження адреси масиву ключів у регістр si
            shl cx, 4                   ; Зміщення значення cx вліво на 4 біти (еквівалент множення на 16)
            add si, cx                  ; Додавання значення cx до si
            shr cx, 4                   ; Зміщення значення cx вправо на 4 біти (еквівалент ділення на 16)
            add si, dx                  ; Додавання значення dx до si
            mov al, [si]                ; Завантаження байту даних з адреси, на яку вказує si, у регістр al
            lea di, keyTemp             ; Завантаження адреси тимчасового ключа у регістр di
            add di, dx                  ; Додавання значення dx до di
            mov ah, [di]                ; Завантаження байту даних з адреси, на яку вказує di, у регістр ah
            cmp al, ah                  ; Порівняння значень al та ah
            jne notEqualChar            ; Якщо вони не рівні, перейти до мітки notEqualChar
            mov bx, 1                   ; Якщо рівні, встановити bx в 1
            jmp contComp                ; Перейти до мітки contComp
        notEqualChar:
            mov bx, 0                   ; Встановити bx в 0
            mov dx, 15                  ; Завантаження 15 у регістр dx
        contComp:
            inc dx                      ; Інкрементування dx
            cmp dx, 16                  ; Порівняння dx з 16
            jnz checkPresKey            ; Якщо не рівні, перейти до мітки checkPresKey


            cmp bx, 0                   ; Перевірка, чи bx дорівнює 0
                jnz keyPresent              ; Якщо не дорівнює, перейти до мітки keyPresent

                inc cx                      ; Інкрементування cx
                cmp cx, newIndex            ; Порівняння cx з newIndex
                jne findKey                 ; Якщо не рівні, перейти до мітки findKey

                mov cx, 0                   ; Очищення регістру cx
                call addNewKeyproc    ; Виклик процедури для додавання нового ключа
                jmp endOfCheck              ; Перейти до мітки endOfCheck

            keyPresent:
                call ifkeypresent          ; Виклик процедури для випадку, коли ключ присутній

            endOfCheck:
                mov keyTempIndex, 0        ; Очищення індексу тимчасового ключа
                mov cx, 0                   ; Очищення регістру cx

                fillZeroskey:
                lea si, keyTemp             ; Завантаження адреси тимчасового ключа у регістр si
                add si, cx                  ; Додавання значення cx до si
                mov [si], 0                 ; Заповнення масиву тимчасового ключа нулями
                inc cx                      ; Інкрементування cx
                cmp cx, 15                  ; Порівняння cx з 15
                jnz fillZeroskey            ; Якщо не рівні, повторити заповнення нулями

                ret
            checkKey endp

            ifkeypresent proc
                mov presIndex, cx           ; Завантаження значення cx у presIndex

                lea si, quantityarray       ; Завантаження адреси масиву кількостей у регістр si
                mov cx, presIndex           ; Завантаження значення presIndex у регістр cx
                shl cx, 1                   ; Зміщення значення cx вліво на 1 біт (еквівалент множення на 2)
                add si, cx                  ; Додавання значення cx до si
                mov ax, [si]                ; Завантаження значення з адреси, на яку вказує si, у регістр ax
                inc ax                      ; Інкрементування ax
                mov [si], ax                ; Збереження нового значення у масиві кількостей
                ret
            ifkeypresent endp

            ; Процедура для додавання нового ключа
            addNewKeyproc proc
                addNewKey:
                lea si, keyTemp             ; Завантаження адреси тимчасового ключа у регістр si
                add si, cx                  ; Додавання значення cx до si
                lea di, keysofarray         ; Завантаження адреси масиву ключів у регістр di
                mov ax, newIndex            ; Завантаження значення newIndex у регістр ax
                shl ax, 4                   ; Зміщення значення ax вліво на 4 біти (еквівалент множення на 16)
                add di, cx                  ; Додавання значення cx до di
                add di, ax                  ; Додавання значення ax до di
                mov al, [si]                ; Завантаження байту даних з адреси, на яку вказує si, у регістр al
                mov [di], al                ; Збереження байту даних у масиві ключів
                inc cx                      ; Інкрементування cx
                cmp cx, 16                  ; Порівняння cx з 16
                jnz addNewKey               ; Якщо не рівні, повторити додавання нового ключа
                mov cx, newIndex            ; Завантаження значення newIndex у регістр cx
                mov presIndex, cx           ; Завантаження значення cx у presIndex
                inc newIndex                ; Інкрементування newIndex

                lea si, quantityarray       ; Завантаження адреси масиву кількостей у регістр si
                mov cx, presIndex           ; Завантаження значення presIndex у регістр cx
                shl cx, 1                   ; Зміщення значення cx вліво на 1 біт (еквівалент множення на 2)
                add si, cx                  ; Додавання значення cx до si
                mov ax, 1                   ; Завантаження 1 у регістр ax
                mov [si], ax                ; Збереження 1 у масиві кількостей
                ret
            addNewKeyproc endp

            ; Процедура для запису масивів
            writeArrays proc
                mov cx, 0                   ; Очищення регістру cx

            makeString:
                mov ax, 0                   ; Очищення регістру ax
                mov presIndex, ax           ; Завантаження 0 у presIndex
                mov dx, 0                   ; Очищення регістру dx
                push cx                     ; Збереження значення cx у стеку


                lea di, quantityarray       ; Завантаження адреси масиву кількостей у регістр di
                    shl cx, 1                   ; Зміщення значення cx вліво на 1 біт (еквівалент множення на 2)
                    add di, cx                  ; Додавання значення cx до di
                    mov cx, [di]                ; Завантаження слова з адреси, на яку вказує di, у регістр cx

                    writeKey:
                    lea si, keysofarray        ; Завантаження адреси масиву ключів у регістр si
                    mov ax, 0                   ; Очищення регістру ax
                    mov ax, cx                  ; Завантаження значення cx у регістр ax
                    shl ax, 4                   ; Зміщення значення ax вліво на 4 біти (еквівалент множення на 16)
                    add si, ax                  ; Додавання значення ax до si
                    add si, presIndex          ; Додавання значення presIndex до si

                    mov ah, 02h                 ; Завантаження 02h у регістр ah (для виводу символу)
                    mov bx, dx                  ; Завантаження значення dx у регістр bx
                    mov dl, [si]                ; Завантаження байту даних з адреси, на яку вказує si, у регістр dl

                    cmp dl, 0                   ; Порівняння значення dl з 0
                    jne notEndOfKey             ; Якщо воно не дорівнює 0, перейти до мітки notEndOfKey
                    jmp gotoNewLine             ; В іншому випадку перейти до мітки gotoNewLine

                    notEndOfKey:
                    int 21h                     ; Виклик системної служби для виводу символу
                    mov dx, bx                  ; Завантаження значення bx у регістр dx
                    inc presIndex               ; Інкрементування presIndex
                    inc dx                      ; Інкрементування dx
                    cmp dx, 16                  ; Порівняння dx з 16
                    jnz writeKey                ; Якщо не рівні, повторити запис ключа

                gotoNewLine:
                    mov ah, 02h                 ; Завантаження 02h у регістр ah (для виводу символу)
                    mov dl, 0dh                 ; Завантаження 0dh у регістр dl (ASCII-код символу каретки)
                    int 21h                     ; Виклик системної служби для виводу символу

                    mov ah, 02h                 ; Завантаження 02h у регістр ah (для виводу символу)
                    mov dl, 0ah                 ; Завантаження 0ah у регістр dl (ASCII-код символу нового рядка)
                    int 21h                     ; Виклик системної служби для виводу символу

                    pop cx                      ; Відновлення значення cx зі стеку
                    inc cx                      ; Інкрементування cx
                    cmp cx, newIndex            ; Порівняння cx з newIndex
                    jnz makeString              ; Якщо не рівні, повторити формування рядка

                    ret
                writeArrays endp
                ; Процедура для додавання мінуса, якщо значення від'ємне
                addMinus proc
                    mov bx, cx                  ; Завантаження значення cx у регістр bx
                    shl bx, 1                   ; Зміщення значення bx вліво на 1 біт (еквівалент множення на 2)
                    mov ax, [valuesarray + bx]  ; Завантаження слова з адреси, обчисленої за допомогою bx, у регістр ax
                    cmp ax, 10000               ; Порівняння ax з 10000
                    jc positiveVal              ; Якщо ax менше за 10000, перейти до мітки positiveVal
                    mov ah, 02h                 ; Завантаження 02h у регістр ah (для виводу символу)
                    mov dl, '-'                 ; Завантаження ASCII-коду мінуса у регістр dl
                    int 21h                     ; Виклик системної служби для виводу символу

                    positiveVal:
                    ret
                addMinus endp
                ; Процедура для обчислення середнього значення
                calcAvr proc
                    mov cx, 0                   ; Очищення регістру cx
                calcAv:
                    lea si, valuesarray         ; Завантаження адреси масиву значень у регістр si
                    shl cx, 1                   ; Зміщення значення cx вліво на 1 біт (еквівалент множення на 2)
                    add si, cx                  ; Додавання значення cx до si
                    lea di, quantityarray       ; Завантаження адреси масиву кількостей у регістр di
                    add di, cx                  ; Додавання значення cx до di
                    shr cx, 1                   ; Зміщення значення cx вправо на 1 біт (еквівалент ділення на 2)
                    mov ax, [si]                ; Завантаження слова з адреси, на яку вказує si, у регістр ax
                    mov bx, [di]                ; Завантаження слова з адреси, на яку вказує di, у регістр bx
                    mov dx, 0                   ; Очищення регістру dx
                    div bx                      ; Ділення ax на bx
                    mov [si], ax                ; Збереження результату у масиві значень
                    inc cx                      ; Інкрементування cx
                    cmp cx, newIndex            ; Порівняння cx з newIndex
                    jnz calcAv                  ; Якщо не рівні, повторити обчислення середнього значення

                    ret
                calcAvr endp


                ; Процедура для сортування масиву
                sortArr proc
                    pop dx                      ; Вилучення значення dx зі стеку

                    mov cx, 0                   ; Очищення регістру cx

                    fillArrayOfPoint:
                    lea di, quantityarray       ; Завантаження адреси масиву кількостей у регістр di
                    shl cx, 1                   ; Зміщення значення cx вліво на 1 біт (еквівалент множення на 2)
                    add di, cx                  ; Додавання значення cx до di
                    shr cx, 1                   ; Зміщення значення cx вправо на 1 біт (еквівалент ділення на 2)
                    mov [di], cx                ; Збереження значення cx у масиві кількостей
                    inc cx                      ; Інкрементування cx
                    cmp cx, newIndex            ; Порівняння cx з newIndex
                    jnz fillArrayOfPoint        ; Якщо не рівні, повторити заповнення масиву вказівників

                    mov cx, word ptr newIndex  ; Завантаження newIndex у регістр cx
                    dec cx                      ; Декрементування cx

                    outerLoop:
                    push cx                     ; Збереження значення cx у стеку
                    lea si, quantityarray       ; Завантаження адреси масиву кількостей у регістр si

                    innerLoop:
                    mov ax, [si]                ; Завантаження слова з адреси, на яку вказує si, у регістр ax
                    push ax                     ; Збереження значення ax у стеку
                    shl ax, 1                   ; Зміщення значення ax вліво на 1 біт (еквівалент множення на 2)
                    add ax, offset valuesarray  ; Додавання значення з offset valuesarray до ax
                    mov di, ax                  ; Завантаження адреси, обчисленої за допомогою ax, у регістр di
                    mov ax, [di]                ; Завантаження слова з адреси, на яку вказує di, у регістр ax
                    mov bx, [si + 2]            ; Завантаження слова з наступної адреси, на яку вказує si, у регістр bx
                    push bx                     ; Збереження значення bx у стеку
                    shl bx, 1                   ; Зміщення значення bx вліво на 1 біт (еквівалент множення на 2)
                    add bx, offset valuesarray  ; Додавання значення з offset valuesarray до bx
                    mov di, bx                  ; Завантаження адреси, обчисленої за допомогою bx, у регістр di
                    mov bx, [di]                ; Завантаження слова з адреси, на яку вказує di, у регістр bx
                    cmp ax, bx                  ; Порівняння ax з bx
                    pop bx                      ; Відновлення значення bx зі стеку
                    pop ax                      ; Відновлення значення ax зі стеку
                    jg nextStep                 ; Якщо ax більше за bx, перейти до мітки nextStep
                    xchg bx, ax                 ; Обмін значеннями bx та ax
                    mov [si], ax                ; Збереження значення ax у масиві кількостей
                    mov [si + 2], bx            ; Збереження значення bx у наступному слові масиву кількостей

                    nextStep:
                    add si, 2                   ; Додавання 2 до si
                    loop innerLoop              ; Повторити внутрішню петлю

                    pop cx                      ; Відновлення значення cx зі стеку
                        loop outerLoop              ; Повторити зовнішню петлю

                        push dx                     ; Збереження значення dx у стеку
                        ret                         ; Повернення з процедури
                    sortArr endp

                    end main

